import 'package:dartz/dartz.dart';
import '../data_sources/local/user_local_ds.dart';
import '../data_sources/remote/user_remote_ds.dart';
import '../models/premium_entitlement_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// Premium Repository
/// Manages premium subscriptions and benefits
/// Reference: Product Documentation §6 (Premium System)
class PremiumRepository {
  final UserLocalDataSource _localDS;
  final UserRemoteDataSource _remoteDS;

  PremiumRepository({
    required UserLocalDataSource localDS,
    required UserRemoteDataSource remoteDS,
  }) : _localDS = localDS,
       _remoteDS = remoteDS;

  // PREMIUM ENTITLEMENT
  Future<Either<Failure, PremiumEntitlementModel?>>
  getPremiumEntitlement() async {
    try {
      final premium = await _localDS.getCurrentPremium();
      return Right(premium);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, PremiumEntitlementModel>> activatePremium(
    PremiumEntitlementModel premium,
  ) async {
    try {
      await _localDS.savePremium(premium);
      await _localDS.updatePremiumStatus(
        isPremium: true,
        premiumTier: premium.tier,
        premiumExpiresAt: premium.expiresAt,
      );

      try {
        await _remoteDS.createPremium(premium);
        // ignore: empty_catches
      } catch (e) {}

      return Right(premium);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updatePremium(
    PremiumEntitlementModel premium,
  ) async {
    try {
      await _localDS.updatePremium(premium);

      try {
        await _remoteDS.updatePremium(premium);
        // ignore: empty_catches
      } catch (e) {}

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // STREAK SHIELDS (3 per month for premium)
  Future<Either<Failure, void>> useStreakShield() async {
    try {
      await _localDS.usePremiumStreakShield();
      return const Right(null);
    } on ValidationException {
      return Left(
        StreakShieldUnavailableFailure(shieldsRemaining: 0, isPremium: true),
      );
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> getStreakShieldsRemaining(String userId) async {
    try {
      final premium = await _localDS.getCurrentPremium();
      return Right(premium?.streakShieldsRemaining ?? 0);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // VACATION DAYS (30 per year for premium)
  Future<Either<Failure, void>> useVacationDay() async {
    try {
      await _localDS.usePremiumVacationDay();
      return const Right(null);
    } on ValidationException {
      return Left(VacationModeUnavailableFailure(0));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> getVacationDaysRemaining(String userId) async {
    try {
      final premium = await _localDS.getCurrentPremium();
      return Right(premium?.vacationDaysRemaining ?? 0);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // PREMIUM STATUS
  Future<Either<Failure, bool>> isPremiumActive() async {
    try {
      final premium = await _localDS.getCurrentPremium();
      return Right(premium?.isPremiumActive ?? false);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, int?>> getDaysUntilExpiry() async {
    try {
      final premium = await _localDS.getCurrentPremium();
      return Right(premium?.daysUntilExpiry);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deactivatePremium() async {
    try {
      await _localDS.deletePremium();
      await _localDS.updatePremiumStatus(
        isPremium: false,
        premiumTier: null,
        premiumExpiresAt: null,
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
