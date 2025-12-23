import 'package:dartz/dartz.dart';
import 'package:habbit_island/data/repositories/complete_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Calculate Streak Use Case
/// Calculates current streak based on completion history

class CalculateStreak {
  final CompletionRepository repository;

  CalculateStreak(this.repository);

  Future<Either<Failure, StreakCalculationResult>> execute({
    required String habitId,
    required String userId,
  }) async {
    try {
      AppLogger.debug('CalculateStreak: Calculating for habit $habitId');

      // Get completions
      final completionsResult = await repository.getCompletions(
        userId: userId,
        habitId: habitId,
      );

      if (completionsResult.isLeft()) {
        return Left((completionsResult as Left).value);
      }

      final completions = (completionsResult as Right).value;

      if (completions.isEmpty) {
        return Right(
          StreakCalculationResult(
            currentStreak: 0,
            longestStreak: 0,
            isActive: false,
          ),
        );
      }

      // Sort by date (newest first)
      completions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      // Calculate current streak
      int currentStreak = 0;
      DateTime? lastDate;

      for (final completion in completions) {
        if (lastDate == null) {
          // First completion
          currentStreak = 1;
          lastDate = completion.completedAt;
        } else {
          final daysDiff = lastDate.difference(completion.completedAt).inDays;

          if (daysDiff == 1) {
            // Consecutive day
            currentStreak++;
            lastDate = completion.completedAt;
          } else if (daysDiff == 0) {
            // Same day (multiple completions)
            continue;
          } else {
            // Gap found, current streak ends
            break;
          }
        }
      }

      // Calculate longest streak
      int longestStreak = currentStreak;
      int tempStreak = 1;
      lastDate = null;

      for (final completion in completions) {
        if (lastDate == null) {
          lastDate = completion.completedAt;
        } else {
          final daysDiff = lastDate.difference(completion.completedAt).inDays;

          if (daysDiff == 1) {
            tempStreak++;
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
          } else if (daysDiff > 1) {
            tempStreak = 1;
          }

          lastDate = completion.completedAt;
        }
      }

      final isActive =
          completions.first.isToday || completions.first.isYesterday;

      AppLogger.info(
        'CalculateStreak: Current=$currentStreak, Longest=$longestStreak',
      );

      return Right(
        StreakCalculationResult(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          isActive: isActive,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('CalculateStreak: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class StreakCalculationResult {
  final int currentStreak;
  final int longestStreak;
  final bool isActive;

  StreakCalculationResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.isActive,
  });
}
