import 'package:dartz/dartz.dart';
import '../data_sources/local/habit_local_ds.dart';
import '../data_sources/remote/habit_remote_ds.dart';
import '../data_sources/local/sync_queue_local_ds.dart';
import '../models/habit_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Habit Repository
/// Combines local and remote data sources with offline-first architecture
/// Reference: Technical Addendum §2 (Offline-First Architecture)

class HabitRepository {
  final HabitLocalDataSource _localDS;
  final HabitRemoteDataSource _remoteDS;
  final SyncQueueLocalDataSource _syncQueueDS;

  HabitRepository({
    required HabitLocalDataSource localDS,
    required HabitRemoteDataSource remoteDS,
    required SyncQueueLocalDataSource syncQueueDS,
  }) : _localDS = localDS,
       _remoteDS = remoteDS,
       _syncQueueDS = syncQueueDS;

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Create new habit (offline-first)
  Future<Either<Failure, HabitModel>> createHabit(HabitModel habit) async {
    try {
      // 1. Validate business rules
      final validationResult = await _validateHabitCreation(habit);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // 2. Save to local storage (always works offline)
      await _localDS.saveHabit(habit);

      // 3. Add to sync queue
      final operation = SyncOperation(
        id: habit.id,
        type: OperationType.create,
        entityType: 'habit',
        entityId: habit.id,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      );
      await _syncQueueDS.addToQueue(operation);

      // 4. Try immediate sync (if online)
      try {
        await _remoteDS.createHabit(habit);
        await _syncQueueDS.markAsSynced(operation.id);
        await _localDS.markHabitAsSynced(habit.id);
      } catch (e) {
        // Sync will happen later in background
      }

      return Right(habit);
    } on HabitLimitException catch (e) {
      return Left(
        HabitLimitFailure(
          currentCount: e.currentCount,
          maxAllowed: e.maxAllowed,
          isPremium: e.isPremium,
        ),
      );
    } on ZoneCapacityException catch (e) {
      return Left(
        ZoneCapacityFailure(zoneName: e.zoneName, maxHabits: e.maxHabits),
      );
    } on DuplicateHabitException catch (e) {
      return Left(DuplicateHabitFailure(e.habitName));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Validate habit creation
  Future<Failure?> _validateHabitCreation(HabitModel habit) async {
    try {
      // Check habit limit (7 free, unlimited premium)
      final habitCount = await _localDS.countHabits(
        habit.userId,
        activeOnly: true,
      );

      // Get user's premium status from user repository
      final isPremium = false; // Placeholder
      final maxHabits = 7;

      if (habitCount >= maxHabits) {
        return HabitLimitFailure(
          currentCount: habitCount,
          maxAllowed: maxHabits,
          isPremium: isPremium,
        );
      }

      // Check zone capacity
      final zoneHabits = await _localDS.countHabitsInZone(
        habit.userId,
        habit.zoneId,
      );
      final zoneMaxHabits = _getZoneMaxHabits(habit.zoneId);

      if (zoneHabits >= zoneMaxHabits) {
        return ZoneCapacityFailure(
          zoneName: habit.zoneId,
          maxHabits: zoneMaxHabits,
        );
      }

      // Check duplicate name
      final nameExists = await _localDS.habitNameExists(
        habit.userId,
        habit.name,
      );

      if (nameExists) {
        return DuplicateHabitFailure(habit.name);
      }

      return null; // Valid
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  int _getZoneMaxHabits(String zoneId) {
    // Reference: Product Documentation §4.3
    switch (zoneId) {
      case 'starter-beach':
        return 4;
      case 'forest-grove':
        return 7;
      case 'mountain-ridge':
        return 10;
      default:
        return 4;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get all habits for user
  Future<Either<Failure, List<HabitModel>>> getHabits(String userId) async {
    try {
      // Always read from local first (offline-first)
      final habits = await _localDS.getAllHabits(userId);

      // Try to sync in background
      _syncHabitsInBackground(userId);

      return Right(habits);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get single habit
  Future<Either<Failure, HabitModel>> getHabit(String habitId) async {
    try {
      final habit = await _localDS.getHabit(habitId);

      if (habit == null) {
        return Left(HabitNotFoundFailure(habitId));
      }

      return Right(habit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get active habits
  Future<Either<Failure, List<HabitModel>>> getActiveHabits(
    String userId,
  ) async {
    try {
      final habits = await _localDS.getActiveHabits(userId);
      return Right(habits);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get habits by zone
  Future<Either<Failure, List<HabitModel>>> getHabitsByZone(
    String userId,
    String zoneId,
  ) async {
    try {
      final habits = await _localDS.getHabitsByZone(userId, zoneId);
      return Right(habits);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get habits by category
  Future<Either<Failure, List<HabitModel>>> getHabitsByCategory(
    String userId,
    HabitCategory category,
  ) async {
    try {
      final habits = await _localDS.getHabitsByCategory(userId, category);
      return Right(habits);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update habit (offline-first)
  Future<Either<Failure, HabitModel>> updateHabit(HabitModel habit) async {
    try {
      // 1. Save to local
      await _localDS.updateHabit(habit);

      // 2. Add to sync queue
      final operation = SyncOperation(
        id: '${habit.id}_update_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.update,
        entityType: 'habit',
        entityId: habit.id,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      );
      await _syncQueueDS.addToQueue(operation);

      // 3. Try immediate sync
      try {
        await _remoteDS.updateHabit(habit);
        await _syncQueueDS.markAsSynced(operation.id);
        await _localDS.markHabitAsSynced(habit.id);
      } catch (e) {
        // Will sync later
      }

      return Right(habit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update habit streak
  Future<Either<Failure, void>> updateHabitStreak(
    String habitId,
    int currentStreak,
    int longestStreak,
    DateTime? lastCompletedAt,
  ) async {
    try {
      await _localDS.updateHabitStreak(
        habitId,
        currentStreak,
        longestStreak,
        lastCompletedAt,
      );

      // Try sync
      try {
        await _remoteDS.updateHabitStreak(
          habitId,
          currentStreak,
          longestStreak,
          lastCompletedAt,
        );
      } catch (e) {
        // Will sync later
      }

      return const Right(null);
    } on NotFoundException {
      return Left(HabitNotFoundFailure(habitId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update decay state
  Future<Either<Failure, void>> updateDecayState(
    String habitId,
    DecayState decayState,
  ) async {
    try {
      await _localDS.updateDecayState(habitId, decayState);
      return const Right(null);
    } on NotFoundException {
      return Left(HabitNotFoundFailure(habitId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update growth level
  Future<Either<Failure, void>> updateGrowthLevel(
    String habitId,
    GrowthLevel growthLevel,
  ) async {
    try {
      await _localDS.updateGrowthLevel(habitId, growthLevel);
      return const Right(null);
    } on NotFoundException {
      return Left(HabitNotFoundFailure(habitId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete habit (offline-first)
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      // 1. Soft delete locally
      await _localDS.softDeleteHabit(habitId);

      // 2. Add to sync queue
      final operation = SyncOperation(
        id: '${habitId}_delete_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.delete,
        entityType: 'habit',
        entityId: habitId,
        data: {'id': habitId},
        timestamp: DateTime.now(),
      );
      await _syncQueueDS.addToQueue(operation);

      // 3. Try immediate sync
      try {
        await _remoteDS.softDeleteHabit(habitId);
        await _syncQueueDS.markAsSynced(operation.id);
      } catch (e) {
        // Will sync later
      }

      return const Right(null);
    } on NotFoundException {
      return Left(HabitNotFoundFailure(habitId));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Hard delete habit (permanent)
  Future<Either<Failure, void>> hardDeleteHabit(String habitId) async {
    try {
      await _localDS.deleteHabit(habitId);

      try {
        await _remoteDS.deleteHabit(habitId);
      } catch (e) {
        // Ignore remote errors for hard delete
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // SYNC
  // ============================================================================

  /// Background sync (call periodically)
  Future<void> _syncHabitsInBackground(String userId) async {
    try {
      // Don't await - run in background
      _remoteDS
          .getHabits(userId)
          .then((remoteHabits) async {
            // Update local with any changes from remote
            await _localDS.saveHabits(remoteHabits);
          })
          .catchError((e) {
            // Ignore sync errors in background
          });
    } catch (e) {
      // Ignore sync errors
    }
  }

  /// Force sync all habits
  Future<Either<Failure, void>> syncHabits(String userId) async {
    try {
      // Get habits needing sync
      final needsSync = await _localDS.getHabitsNeedingSync(userId);

      if (needsSync.isEmpty) {
        return const Right(null);
      }

      // Batch update on remote
      await _remoteDS.batchUpdateHabits(needsSync);

      // Mark all as synced
      for (final habit in needsSync) {
        await _localDS.markHabitAsSynced(habit.id);
      }

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
