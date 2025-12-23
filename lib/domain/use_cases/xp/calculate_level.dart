import 'package:dartz/dartz.dart';
import '../../../data/repositories/xp_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Calculate Level Use Case
/// Calculates user level and XP statistics

class CalculateLevel {
  final XpRepository repository;

  CalculateLevel(this.repository);

  /// Calculate level from total XP (100 XP per level)
  Future<Either<Failure, LevelCalculationResult>> execute({
    required String userId,
  }) async {
    try {
      AppLogger.debug('CalculateLevel: Calculating for user $userId');

      // Get XP statistics
      final statsResult = await repository.getXpStatistics(userId);

      if (statsResult.isLeft()) {
        return Left((statsResult as Left).value);
      }

      final stats = (statsResult as Right).value;

      final level = repository.calculateLevel(stats.totalXp);
      final xpForNext = repository.getXpRequiredForNextLevel(level);
      final xpRemaining = repository.getXpRemainingForNextLevel(stats.totalXp);
      final progress = repository.getLevelProgress(stats.totalXp);

      AppLogger.debug('CalculateLevel: Level $level ($progress% to next)');

      return Right(
        LevelCalculationResult(
          currentLevel: level,
          totalXp: stats.totalXp,
          xpRequiredForNextLevel: xpForNext,
          xpRemainingForNextLevel: xpRemaining,
          progressToNextLevel: progress,
          xpToday: stats.xpToday,
          xpThisWeek: stats.xpThisWeek,
          xpThisMonth: stats.xpThisMonth,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('CalculateLevel: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Get XP required for specific level
  int getXpForLevel(int targetLevel) {
    return repository.getXpRequiredForLevel(targetLevel);
  }
}

class LevelCalculationResult {
  final int currentLevel;
  final int totalXp;
  final int xpRequiredForNextLevel;
  final int xpRemainingForNextLevel;
  final double progressToNextLevel;
  final int xpToday;
  final int xpThisWeek;
  final int xpThisMonth;

  LevelCalculationResult({
    required this.currentLevel,
    required this.totalXp,
    required this.xpRequiredForNextLevel,
    required this.xpRemainingForNextLevel,
    required this.progressToNextLevel,
    required this.xpToday,
    required this.xpThisWeek,
    required this.xpThisMonth,
  });
}
