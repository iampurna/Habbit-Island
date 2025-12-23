import 'package:dartz/dartz.dart';
import '../../entities/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../data/repositories/premium_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Use Streak Shield Use Case
/// Uses a premium streak shield to protect a habit's streak

class UseStreakShield {
  final HabitRepository habitRepository;
  final PremiumRepository premiumRepository;

  UseStreakShield({
    required this.habitRepository,
    required this.premiumRepository,
  });

  Future<Either<Failure, StreakShieldResult>> execute({
    required String userId,
    required String habitId,
  }) async {
    try {
      AppLogger.debug('UseStreakShield: Protecting habit $habitId');

      // Check if user has shields available
      final shieldsRemaining = await premiumRepository
          .getStreakShieldsRemaining(userId);

      if (shieldsRemaining.isLeft()) {
        return Left((shieldsRemaining as Left).value);
      }

      final shields = (shieldsRemaining as Right<Failure, int>).value;

      if (shields <= 0) {
        AppLogger.warning('UseStreakShield: No shields available');
        return Left(
          StreakShieldUnavailableFailure('No streak shields remaining'),
        );
      }

      // Get habit
      final habitResult = await habitRepository.getHabit(habitId);
      if (habitResult.isLeft()) {
        return Left((habitResult as Left).value);
      }

      final habit = (habitResult as Right<Failure, Habit>).value;

      // Validate streak can be shielded
      if (habit.currentStreak == 0) {
        return Left(ValidationFailure('No active streak to protect'));
      }

      if (habit.isCompletedToday) {
        return Left(ValidationFailure('Habit already completed today'));
      }

      // Use shield
      final useResult = await premiumRepository.useStreakShield(userId);
      if (useResult.isLeft()) {
        return Left((useResult as Left).value);
      }

      // Update habit with protected status
      final updatedHabit = habit.copyWith(
        lastCompletedAt: DateTime.now(), // Treat as completed
        updatedAt: DateTime.now(),
      );

      await habitRepository.updateHabit(updatedHabit);

      AppLogger.info(
        'UseStreakShield: Success - Shield used, ${shields - 1} remaining',
      );

      return Right(
        StreakShieldResult(
          habit: updatedHabit,
          shieldsRemaining: shields - 1,
          streakProtected: habit.currentStreak,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('UseStreakShield: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class StreakShieldResult {
  final Habit habit;
  final int shieldsRemaining;
  final int streakProtected;

  StreakShieldResult({
    required this.habit,
    required this.shieldsRemaining,
    required this.streakProtected,
  });
}
