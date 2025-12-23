import 'package:dartz/dartz.dart';
import '../../entities/habit.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Evaluate Decay Use Case
/// Checks and applies decay to habits based on inactivity

class EvaluateDecay {
  final HabitRepository repository;

  EvaluateDecay(this.repository);

  Future<Either<Failure, DecayEvaluationResult>> execute({
    required String habitId,
  }) async {
    try {
      AppLogger.debug('EvaluateDecay: Evaluating habit $habitId');

      // Get habit
      final habitResult = await repository.getHabit(habitId);
      if (habitResult.isLeft()) {
        return Left((habitResult as Left).value);
      }

      final habit = (habitResult as Right<Failure, Habit>).value;

      // Check if decay is needed
      if (!habit.needsDecayCheck) {
        return Right(
          DecayEvaluationResult(
            decayApplied: false,
            decaySeverity: 0,
            newGrowthLevel: habit.growthLevel,
          ),
        );
      }

      final severity = habit.decaySeverity;
      int growthLevelLost = 0;

      // Apply decay based on severity
      switch (severity) {
        case 1: // Minor decay (2-3 days)
          growthLevelLost = 1;
          break;
        case 2: // Moderate decay (4-6 days)
          growthLevelLost = 3;
          break;
        case 3: // Severe decay (7+ days)
          growthLevelLost = 5;
          break;
        default:
          growthLevelLost = 0;
      }

      if (growthLevelLost > 0) {
        final newGrowthLevel = (habit.growthLevel - growthLevelLost).clamp(
          0,
          999,
        );

        final updatedHabit = habit.copyWith(
          growthLevel: newGrowthLevel,
          decayCounter: habit.decayCounter + 1,
          updatedAt: DateTime.now(),
        );

        await repository.updateDecayState(
          habitId: habitId,
          decayCounter: updatedHabit.decayCounter,
          growthLevel: newGrowthLevel,
        );

        AppLogger.warning(
          'EvaluateDecay: Applied decay - Lost $growthLevelLost growth levels',
        );

        return Right(
          DecayEvaluationResult(
            decayApplied: true,
            decaySeverity: severity,
            newGrowthLevel: newGrowthLevel,
            growthLevelLost: growthLevelLost,
          ),
        );
      }

      return Right(
        DecayEvaluationResult(
          decayApplied: false,
          decaySeverity: severity,
          newGrowthLevel: habit.growthLevel,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('EvaluateDecay: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class DecayEvaluationResult {
  final bool decayApplied;
  final int decaySeverity;
  final int newGrowthLevel;
  final int? growthLevelLost;

  DecayEvaluationResult({
    required this.decayApplied,
    required this.decaySeverity,
    required this.newGrowthLevel,
    this.growthLevelLost,
  });
}
