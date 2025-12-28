import 'package:dartz/dartz.dart';
import 'package:habbit_island/data/services/storage_service.dart';
import '../data_sources/local/user_local_ds.dart';
import '../data_sources/remote/user_remote_ds.dart';
import '../models/user_model.dart';
import '../models/premium_entitlement_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// User Repository
/// Manages user profile and premium entitlements
class UserRepository {
  final UserLocalDataSource _localDS;
  final UserRemoteDataSource _remoteDS;

  UserRepository({
    required UserLocalDataSource localDS,
    required UserRemoteDataSource remoteDS,
    required StorageService storageService,
  }) : _localDS = localDS,
       _remoteDS = remoteDS;

  // ============================================================================
  // USER OPERATIONS
  // ============================================================================

  /// Get current user
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = await _localDS.getCurrentUser();

      if (user == null) {
        return const Left(NotFoundFailure('User not found'));
      }

      // Try background sync
      _syncUserInBackground(user.id);

      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Create new user
  Future<Either<Failure, UserModel>> createUser(UserModel user) async {
    try {
      // Save locally
      await _localDS.saveUser(user);

      // Try create remotely
      try {
        await _remoteDS.createUser(user);
        await _localDS.markUserAsSynced();
      } catch (e) {
        // Will sync later
      }

      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update user
  Future<Either<Failure, UserModel>> updateUser(UserModel user) async {
    try {
      await _localDS.updateUser(user);

      try {
        await _remoteDS.updateUser(user);
        await _localDS.markUserAsSynced();
      } catch (e) {
        // Will sync later
      }

      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Add XP to user
  Future<Either<Failure, void>> addXp(int xpAmount) async {
    try {
      await _localDS.addXp(xpAmount);

      final user = await _localDS.getCurrentUser();
      if (user != null) {
        try {
          await _remoteDS.addXp(user.id, xpAmount);
        } catch (e) {
          // Will sync later
        }
      }

      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Unlock zone
  Future<Either<Failure, void>> unlockZone(String zoneId) async {
    try {
      await _localDS.unlockZone(zoneId);

      final user = await _localDS.getCurrentUser();
      if (user != null) {
        try {
          await _remoteDS.unlockZone(user.id, zoneId);
        } catch (e) {
          // Will sync later
        }
      }

      return const Right(null);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Update last login
  Future<Either<Failure, void>> updateLastLogin() async {
    try {
      await _localDS.updateLastLogin();

      final user = await _localDS.getCurrentUser();
      if (user != null) {
        try {
          await _remoteDS.updateLastLogin(user.id);
        } catch (e) {
          // Ignore - not critical
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Use streak shield
  Future<Either<Failure, void>> useStreakShield() async {
    try {
      await _localDS.useStreakShield();
      return const Right(null);
    } on ValidationException {
      return Left(
        StreakShieldUnavailableFailure(shieldsRemaining: 0, isPremium: false),
      );
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Use vacation day
  Future<Either<Failure, void>> useVacationDay() async {
    try {
      await _localDS.useVacationDay();
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

  // ============================================================================
  // PREMIUM OPERATIONS
  // ============================================================================

  /// Get premium entitlement
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

  /// Activate premium
  Future<Either<Failure, PremiumEntitlementModel>> activatePremium(
    PremiumEntitlementModel premium,
  ) async {
    try {
      // Save locally
      await _localDS.savePremium(premium);

      // Update user premium status
      await _localDS.updatePremiumStatus(
        isPremium: true,
        premiumTier: premium.tier,
        premiumExpiresAt: premium.expiresAt,
      );

      // Sync to remote
      try {
        await _remoteDS.createPremium(premium);
      } catch (e) {
        // Will sync later
      }

      return Right(premium);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Use premium streak shield
  Future<Either<Failure, void>> usePremiumStreakShield() async {
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

  /// Sync user data
  Future<Either<Failure, void>> syncUser(String userId) async {
    try {
      final remoteUser = await _remoteDS.getUser(userId);

      if (remoteUser != null) {
        await _localDS.saveUser(remoteUser);
        await _localDS.markUserAsSynced();
      }

      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Background sync
  Future<void> _syncUserInBackground(String userId) async {
    try {
      _remoteDS
          .getUser(userId)
          .then((remoteUser) async {
            if (remoteUser != null) {
              await _localDS.saveUser(remoteUser);
            }
          })
          .catchError((e) {});
      // ignore: empty_catches
    } catch (e) {}
  }

  /// Delete user
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await _localDS.deleteUser();
      await _localDS.deletePremium();

      try {
        await _remoteDS.deleteUser(userId);
      } catch (e) {
        // Ignore remote errors
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
