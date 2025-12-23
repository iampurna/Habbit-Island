import 'package:dartz/dartz.dart';
import 'package:habbit_island/data/repositories/complete_repository.dart';
import '../../entities/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../data/repositories/xp_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Complete Habit Use Case
/// Orchestrates habit completion, XP award, and streak updates

class CompleteHabit {
  final HabitRepository habitRepository;
  final CompletionRepository completionRepository;
  final XpRepository xpRepository;

  CompleteHabit({
    required this.habitRepository,
    required this.completionRepository,
    required this.xpRepository,
  });

  Future<Either<Failure, CompleteHabitResult>> execute({
    required String userId,
    required String habitId,
    String? notes,
  }) async {
    try {
      AppLogger.debug('CompleteHabit: Completing habit $habitId');

      // 1. Get habit
      final habitResult = await habitRepository.getHabit(habitId);
      if (habitResult.isLeft()) {
        return Left((habitResult as Left).value);
      }

      final habit = (habitResult as Right<Failure, Habit>).value;

      // 2. Check if already completed today
      if (habit.isCompletedToday) {
        AppLogger.warning('CompleteHabit: Habit already completed today');
        return Left(ValidationFailure('Habit already completed today'));
      }

      // 3. Create completion record
      final completionResult = await completionRepository.createCompletion(
        habitId: habitId,
        userId: userId,
        completedAt: DateTime.now(),
        notes: notes,
      );

      if (completionResult.isLeft()) {
        return Left((completionResult as Left).value);
      }

      // 4. Award XP (repository handles bonuses)
      final xpResult = await xpRepository.awardHabitCompletionXp(
        userId: userId,
        habitId: habitId,
      );

      int totalXpEarned = 0;
      bool hadBonus = false;
      if (xpResult.isRight()) {
        final xpAward = (xpResult as Right).value;
        totalXpEarned = xpAward.totalXpAwarded;
        hadBonus = xpAward.hasBonus;
      }

      // 5. Update habit (streak, last completed, growth)
      final updatedHabit = habit.copyWith(
        lastCompletedAt: DateTime.now(),
        totalCompletions: habit.totalCompletions + 1,
        currentStreak: habit.currentStreak + 1,
        longestStreak: habit.longestStreak < habit.currentStreak + 1
            ? habit.currentStreak + 1
            : habit.longestStreak,
        growthLevel: habit.growthLevel + 1,
        updatedAt: DateTime.now(),
      );

      await habitRepository.updateHabit(updatedHabit);

      AppLogger.info('CompleteHabit: Success - Earned $totalXpEarned XP');

      return Right(
        CompleteHabitResult(
          habit: updatedHabit,
          xpEarned: totalXpEarned,
          hadBonus: hadBonus,
          newStreak: updatedHabit.currentStreak,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('CompleteHabit: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

/// Result of completing a habit
class CompleteHabitResult {
  final Habit habit;
  final int xpEarned;
  final bool hadBonus;
  final int newStreak;

  CompleteHabitResult({
    required this.habit,
    required this.xpEarned,
    required this.hadBonus,
    required this.newStreak,
  });
}
