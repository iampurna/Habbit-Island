import 'package:dartz/dartz.dart';
import 'package:habbit_island/domain/use_cases/habits/complete_habit.dart';
import '../../entities/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Create Habit Use Case
/// Handles habit creation with validation and business rules

class CreateHabit {
  final HabitRepository repository;

  CreateHabit(this.repository);

  Future<Either<Failure, Habit>> execute({
    required String userId,
    required String name,
    String? description,
    required HabitCategory category,
    required HabitFrequency frequency,
    String? customFrequencyDays,
    required String zoneId,
    String? reminderTime,
  }) async {
    try {
      AppLogger.debug('CreateHabit: Creating habit "$name" for user $userId');

      // Validate inputs
      if (!Habit.isValidName(name)) {
        return Left(ValidationFailure('Invalid habit name'));
      }

      if (zoneId.isEmpty) {
        return Left(ValidationFailure('Zone ID is required'));
      }

      // Create habit (repository handles limits and validation)
      final result = await repository.createHabit(
        userId: userId,
        name: name,
        description: description,
        category: category,
        frequency: frequency,
        customFrequencyDays: customFrequencyDays,
        zoneId: zoneId,
        reminderTime: reminderTime,
      );

      return result.fold(
        (failure) {
          AppLogger.warning('CreateHabit: Failed - ${failure.message}');
          return Left(failure);
        },
        (habit) {
          AppLogger.info('CreateHabit: Success - Habit ${habit.id} created');
          return Right(habit as Habit);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('CreateHabit: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
