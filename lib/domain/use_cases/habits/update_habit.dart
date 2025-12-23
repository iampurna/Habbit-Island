import 'package:dartz/dartz.dart';
import '../../entities/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Update Habit Use Case
/// Updates habit properties with validation

class UpdateHabit {
  final HabitRepository repository;

  UpdateHabit(this.repository);

  Future<Either<Failure, Habit>> execute({
    required String habitId,
    String? name,
    String? description,
    HabitCategory? category,
    HabitFrequency? frequency,
    String? zoneId,
    String? reminderTime,
    bool? isActive,
  }) async {
    try {
      AppLogger.debug('UpdateHabit: Updating habit $habitId');

      // Get existing habit
      final habitResult = await repository.getHabit(habitId);
      if (habitResult.isLeft()) {
        return Left((habitResult as Left).value);
      }

      final habit = (habitResult as Right<Failure, Habit>).value;

      // Validate name if provided
      if (name != null && !Habit.isValidName(name)) {
        return Left(ValidationFailure('Invalid habit name'));
      }

      // Update habit with new values
      final updatedHabit = habit.copyWith(
        name: name,
        description: description,
        category: category,
        frequency: frequency,
        zoneId: zoneId,
        reminderTime: reminderTime,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateHabit(updatedHabit);

      return result.fold(
        (failure) {
          AppLogger.warning('UpdateHabit: Failed - ${failure.message}');
          return Left(failure);
        },
        (habit) {
          AppLogger.info('UpdateHabit: Success - Habit $habitId updated');
          return Right(habit);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('UpdateHabit: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
