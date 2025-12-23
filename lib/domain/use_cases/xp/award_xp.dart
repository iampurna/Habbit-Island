import 'package:dartz/dartz.dart';
import '../../../data/repositories/xp_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/app_logger.dart';

/// Award XP Use Case
/// Awards XP to user from various sources with automatic bonus detection

class AwardXp {
  final XpRepository repository;

  AwardXp(this.repository);

  /// Award XP for habit completion (automatically checks for bonuses)
  Future<Either<Failure, XpAwardResult>> forHabitCompletion({
    required String userId,
    required String habitId,
  }) async {
    try {
      AppLogger.debug('AwardXp: Awarding for habit completion');

      final result = await repository.awardHabitCompletionXp(
        userId: userId,
        habitId: habitId,
      );

      return result.fold(
        (failure) {
          AppLogger.warning('AwardXp: Failed - ${failure.message}');
          return Left(failure);
        },
        (award) {
          AppLogger.info('AwardXp: Awarded ${award.totalXpAwarded} XP');
          return Right(
            XpAwardResult(
              xpAwarded: award.totalXpAwarded,
              hasBonus: award.hasBonus,
              bonusType: award.bonusType,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AwardXp: Unexpected error', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Award XP for daily login
  Future<Either<Failure, int>> forDailyLogin({required String userId}) async {
    try {
      AppLogger.debug('AwardXp: Awarding for daily login');

      final result = await repository.awardDailyLoginXp(userId);

      return result.fold((failure) => Left(failure), (award) {
        AppLogger.info('AwardXp: Daily login +${award.totalXpAwarded} XP');
        return Right(award.totalXpAwarded);
      });
    } catch (e, stackTrace) {
      AppLogger.error('AwardXp: Error awarding login XP', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Award XP for watching rewarded ad
  Future<Either<Failure, int>> forRewardedAd({
    required String userId,
    required String adId,
  }) async {
    try {
      AppLogger.debug('AwardXp: Awarding for rewarded ad');

      final result = await repository.awardRewardedAdXp(
        userId: userId,
        adId: adId,
      );

      return result.fold(
        (failure) {
          if (failure is AdLimitFailure) {
            AppLogger.warning('AwardXp: Daily ad limit reached');
          }
          return Left(failure);
        },
        (award) {
          AppLogger.info('AwardXp: Rewarded ad +${award.totalXpAwarded} XP');
          return Right(award.totalXpAwarded);
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AwardXp: Error awarding ad XP', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Award manual XP (admin/promotional)
  Future<Either<Failure, int>> manual({
    required String userId,
    required int amount,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.info('AwardXp: Manual award of $amount XP');

      final result = await repository.awardManualXp(
        userId: userId,
        amount: amount,
        description: description,
        metadata: metadata,
      );

      return result.fold(
        (failure) => Left(failure),
        (award) => Right(award.totalXpAwarded),
      );
    } catch (e, stackTrace) {
      AppLogger.error('AwardXp: Error awarding manual XP', e, stackTrace);
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class XpAwardResult {
  final int xpAwarded;
  final bool hasBonus;
  final String? bonusType;

  XpAwardResult({
    required this.xpAwarded,
    required this.hasBonus,
    this.bonusType,
  });
}
