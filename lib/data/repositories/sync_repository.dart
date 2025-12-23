import 'package:dartz/dartz.dart';
import 'package:habbit_island/data/data_sources/local/completion_local_ds.dart';
import 'package:habbit_island/data/data_sources/remote/completion_remote_ds.dart';
import 'package:habbit_island/data/models/habit_completion_model.dart';
import 'package:habbit_island/data/models/habit_model.dart';
import 'package:habbit_island/data/models/user_model.dart';
import '../data_sources/local/habit_local_ds.dart';
import '../data_sources/local/user_local_ds.dart';
import '../data_sources/local/sync_queue_local_ds.dart';
import '../data_sources/remote/sync_remote_ds.dart';
import '../data_sources/remote/habit_remote_ds.dart';
import '../data_sources/remote/user_remote_ds.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Sync Repository
/// Handles bidirectional sync between local and remote data
/// Reference: Technical Addendum §2.3 (Sync Strategy)
class SyncRepository {
  final HabitLocalDataSource _habitLocalDS;
  final UserLocalDataSource _userLocalDS;
  final CompletionsLocalDataSource _completionsLocalDS;
  final SyncQueueLocalDataSource _syncQueueDS;
  final SyncRemoteDataSource _syncRemoteDS;
  final HabitRemoteDataSource _habitRemoteDS;
  final UserRemoteDataSource _userRemoteDS;
  final CompletionsRemoteDataSource _completionsRemoteDS;

  SyncRepository({
    required HabitLocalDataSource habitLocalDS,
    required UserLocalDataSource userLocalDS,
    required CompletionsLocalDataSource completionsLocalDS,
    required SyncQueueLocalDataSource syncQueueDS,
    required SyncRemoteDataSource syncRemoteDS,
    required HabitRemoteDataSource habitRemoteDS,
    required UserRemoteDataSource userRemoteDS,
    required CompletionsRemoteDataSource completionsRemoteDS,
  }) : _habitLocalDS = habitLocalDS,
       _userLocalDS = userLocalDS,
       _completionsLocalDS = completionsLocalDS,
       _syncQueueDS = syncQueueDS,
       _syncRemoteDS = syncRemoteDS,
       _habitRemoteDS = habitRemoteDS,
       _userRemoteDS = userRemoteDS,
       _completionsRemoteDS = completionsRemoteDS;

  /// Full bidirectional sync
  Future<Either<Failure, void>> fullSync(String userId) async {
    try {
      // 1. PULL: Get all data from server
      final lastSyncTime = await _syncRemoteDS.getLastSyncTime(userId);
      final pullResult = await _syncRemoteDS.pullUserData(userId, lastSyncTime);

      // 2. Update local with remote data
      await _habitLocalDS.saveHabits(pullResult.habits);
      for (final completion in pullResult.completions) {
        await _completionsLocalDS.saveCompletion(completion);
      }
      await _userLocalDS.saveUser(pullResult.user);

      // 3. PUSH: Send pending changes to server
      await _processSyncQueue(userId);

      // 4. Update last sync time
      await _syncRemoteDS.updateLastSyncTime(userId);

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

  /// Process sync queue (push local changes)
  Future<Either<Failure, void>> processSyncQueue(String userId) async {
    try {
      await _processSyncQueue(userId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<void> _processSyncQueue(String userId) async {
    final pending = await _syncQueueDS.getAllPending();

    for (final operation in pending) {
      try {
        await _syncQueueDS.updateOperationStatus(
          operation.id,
          SyncStatus.syncing,
        );

        await _executeOperation(operation);

        await _syncQueueDS.markAsSynced(operation.id);
      } catch (e) {
        await _syncQueueDS.markAsFailed(operation.id, e.toString());
      }
    }
  }

  Future<void> _executeOperation(SyncOperation operation) async {
    switch (operation.entityType) {
      case 'habit':
        await _executeHabitOperation(operation);
        break;
      case 'completion':
        await _executeCompletionOperation(operation);
        break;
      case 'user':
        await _executeUserOperation(operation);
        break;
      default:
        throw Exception('Unknown entity type: ${operation.entityType}');
    }
  }

  Future<void> _executeHabitOperation(SyncOperation operation) async {
    switch (operation.type) {
      case OperationType.create:
        await _habitRemoteDS.createHabit(HabitModel.fromJson(operation.data));
        break;
      case OperationType.update:
        await _habitRemoteDS.updateHabit(HabitModel.fromJson(operation.data));
        break;
      case OperationType.delete:
        await _habitRemoteDS.deleteHabit(operation.entityId);
        break;
    }
  }

  Future<void> _executeCompletionOperation(SyncOperation operation) async {
    switch (operation.type) {
      case OperationType.create:
        await _completionsRemoteDS.createCompletion(
          HabitCompletionModel.fromJson(operation.data),
        );
        break;
      case OperationType.delete:
        await _completionsRemoteDS.deleteCompletion(operation.entityId);
        break;
      default:
        break;
    }
  }

  Future<void> _executeUserOperation(SyncOperation operation) async {
    switch (operation.type) {
      case OperationType.update:
        await _userRemoteDS.updateUser(UserModel.fromJson(operation.data));
        break;
      default:
        break;
    }
  }

  /// Get sync status
  Future<Either<Failure, SyncStatus>> getSyncStatus() async {
    try {
      final size = await _syncQueueDS.getQueueSize();

      if (size == 0) {
        return const Right(SyncStatus.synced);
      } else {
        return const Right(SyncStatus.pending);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get pending operations count
  Future<Either<Failure, int>> getPendingCount() async {
    try {
      final size = await _syncQueueDS.getQueueSize();
      return Right(size);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Retry failed operations
  Future<Either<Failure, void>> retryFailedOperations() async {
    try {
      final retryable = await _syncQueueDS.getRetryableOperations();

      for (final operation in retryable) {
        try {
          await _executeOperation(operation);
          await _syncQueueDS.markAsSynced(operation.id);
        } catch (e) {
          await _syncQueueDS.markAsFailed(operation.id, e.toString());
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Clear sync queue
  Future<Either<Failure, void>> clearSyncQueue() async {
    try {
      await _syncQueueDS.clearSynced();
      await _syncQueueDS.clearFailed();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
