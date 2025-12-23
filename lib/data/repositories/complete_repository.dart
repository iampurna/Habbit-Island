import 'package:dartz/dartz.dart';
import 'package:habbit_island/data/data_sources/local/completion_local_ds.dart';
import 'package:habbit_island/data/data_sources/remote/completion_remote_ds.dart';
import '../data_sources/local/sync_queue_local_ds.dart';
import '../models/habit_completion_model.dart';
import '../models/habit_streak_model.dart';
import '../models/xp_event_model.dart';
import '../models/island_state_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Completion Repository
/// Manages habit completions, streaks, XP events, and island state
class CompletionRepository {
  final CompletionsLocalDataSource _localDS;
  final CompletionsRemoteDataSource _remoteDS;
  final SyncQueueLocalDataSource _syncQueueDS;

  CompletionRepository({
    required CompletionsLocalDataSource localDS,
    required CompletionsRemoteDataSource remoteDS,
    required SyncQueueLocalDataSource syncQueueDS,
  }) : _localDS = localDS,
       _remoteDS = remoteDS,
       _syncQueueDS = syncQueueDS;

  // COMPLETIONS
  Future<Either<Failure, HabitCompletionModel>> createCompletion(
    HabitCompletionModel completion,
  ) async {
    try {
      await _localDS.saveCompletion(completion);

      final operation = SyncOperation(
        id: completion.id,
        type: OperationType.create,
        entityType: 'completion',
        entityId: completion.id,
        data: completion.toJson(),
        timestamp: DateTime.now(),
      );
      await _syncQueueDS.addToQueue(operation);

      try {
        await _remoteDS.createCompletion(completion);
        await _syncQueueDS.markAsSynced(operation.id);
        // ignore: empty_catches
      } catch (e) {}

      return Right(completion);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<HabitCompletionModel>>> getCompletions(
    String habitId, {
    required String userId,
  }) async {
    try {
      final completions = await _localDS.getCompletions(habitId);
      return Right(completions);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCompletion(String completionId) async {
    try {
      await _localDS.deleteCompletion(completionId);

      try {
        await _remoteDS.deleteCompletion(completionId);
        // ignore: empty_catches
      } catch (e) {}

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // STREAKS
  Future<Either<Failure, HabitStreakModel>> getStreak(String habitId) async {
    try {
      final streak = await _localDS.getStreak(habitId);

      if (streak == null) {
        return Left(NotFoundFailure('Streak not found: $habitId'));
      }

      return Right(streak);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateStreak(HabitStreakModel streak) async {
    try {
      await _localDS.saveStreak(streak);

      try {
        await _remoteDS.updateStreak(streak);
        // ignore: empty_catches
      } catch (e) {}

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // XP EVENTS
  Future<Either<Failure, XpEventModel>> createXpEvent(
    XpEventModel event,
  ) async {
    try {
      await _localDS.saveXpEvent(event);

      try {
        await _remoteDS.createXpEvent(event);
        // ignore: empty_catches
      } catch (e) {}

      return Right(event);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<XpEventModel>>> getXpEvents(String userId) async {
    try {
      final events = await _localDS.getXpEvents(userId);
      return Right(events);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ISLAND STATE
  Future<Either<Failure, IslandStateModel>> getIsland(String islandId) async {
    try {
      final island = await _localDS.getIsland(islandId);

      if (island == null) {
        return Left(NotFoundFailure('Island not found: $islandId'));
      }

      return Right(island);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateIsland(IslandStateModel island) async {
    try {
      await _localDS.saveIsland(island);

      try {
        await _remoteDS.updateIsland(island);
        // ignore: empty_catches
      } catch (e) {}

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
