import 'package:dartz/dartz.dart';
import 'package:habbit_island/domain/use_cases/habits/complete_habit.dart';
import '../../entities/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Get Habits Use Case
/// Retrieves user's habits with optional filtering

class GetHabits {
  final HabitRepository repository;

  GetHabits(this.repository);

  Future<Either<Failure, List<Habit>>> execute({
    required String userId,
    bool activeOnly = false,
    String? zoneId,
    HabitCategory? category,
  }) async {
    try {
      AppLogger.debug('GetHabits: Fetching habits for user $userId');

      Either<Failure, List<Habit>> result;

      if (zoneId != null) {
        result =
            (await repository.getHabitsByZone(userId, zoneId))
                as Either<Failure, List<Habit>>;
      } else if (category != null) {
        result =
            (await repository.getHabitsByCategory(userId, category))
                as Either<Failure, List<Habit>>;
      } else if (activeOnly) {
        result =
            (await repository.getActiveHabits(userId))
                as Either<Failure, List<Habit>>;
      } else {
        result =
            (await repository.getHabits(userId))
                as Either<Failure, List<Habit>>;
      }

      return result.fold(
        (failure) {
          AppLogger.warning('GetHabits: Failed - ${failure.message}');
          return Left(failure);
        },
        (habits) {
          AppLogger.debug('GetHabits: Retrieved ${habits.length} habits');
          return Right(habits);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('GetHabits: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
