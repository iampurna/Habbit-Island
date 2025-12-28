import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../../core/utils/app_logger.dart';

/// Auth Repository
/// Handles all authentication operations with offline-first approach
class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  AuthRepository({
    required AuthService authService,
    required StorageService storageService,
  }) : _authService = authService,
       _storageService = storageService;

  // ============================================================================
  // SIGN UP
  // ============================================================================

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLogger.info('AuthRepository: Signing up user with email: $email');

      // Sign up via auth service
      final authUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Create user model
      final userModel = UserModel(
        id: authUser.id,
        email: authUser.email,
        displayName: displayName ?? authUser.displayName ?? 'User',
        photoUrl: authUser.photoUrl,
        isPremium: false,
        totalXp: 0,
        currentLevel: 1,
        streakShieldsRemaining: 0,
        vacationDaysRemaining: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentIslandId: '',
      );

      // Save to local storage
      await _storageService.saveUser(userModel);

      // Create user record in remote database
      await _storageService.syncUserToRemote(userModel);

      AppLogger.info('AuthRepository: User signed up successfully');
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Sign up failed', e);
      return Left(AuthFailure(e.message));
    } on CacheException catch (e) {
      AppLogger.error('AuthRepository: Cache error during sign up', e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthRepository: Unexpected sign up error',
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to sign up: ${e.toString()}'));
    }
  }

  // ============================================================================
  // SIGN IN
  // ============================================================================

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('AuthRepository: Signing in user with email: $email');

      // Sign in via auth service
      final authUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // Try to get user from local cache first
      User? user = await _getUserFromCache(authUser.id);

      if (user == null) {
        // Fetch from remote if not in cache
        user = await _fetchUserFromRemote(authUser.id);

        if (user == null) {
          // Create new user record if doesn't exist
          final userModel = UserModel(
            id: authUser.id,
            email: authUser.email ?? email,
            displayName: authUser.displayName ?? 'User',
            photoUrl: authUser.photoUrl,
            isPremium: false,
            totalXp: 0,
            currentLevel: 1,
            streakShieldsRemaining: 0,
            vacationDaysRemaining: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentIslandId: '',
          );

          await _storageService.saveUser(userModel);
          await _storageService.syncUserToRemote(userModel);
          user = userModel.toEntity();
        }
      }

      AppLogger.info('AuthRepository: User signed in successfully');
      return Right(user!);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Sign in failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthRepository: Unexpected sign in error',
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to sign in: ${e.toString()}'));
    }
  }

  /// Sign in with Google
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      AppLogger.info('AuthRepository: Signing in with Google');

      final authUser = await _authService.signInWithGoogle();

      // Try to get user from local cache
      User? user = await _getUserFromCache(authUser.id);

      if (user == null) {
        // Fetch from remote or create new
        user = await _fetchUserFromRemote(authUser.id);

        if (user == null) {
          final userModel = UserModel(
            id: authUser.id,
            email: authUser.email ?? '',
            displayName: authUser.displayName ?? 'User',
            photoUrl: authUser.photoUrl,
            isPremium: false,
            totalXp: 0,
            currentLevel: 1,
            streakShieldsRemaining: 0,
            vacationDaysRemaining: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _storageService.saveUser(userModel);
          await _storageService.syncUserToRemote(userModel);
          user = userModel.toEntity();
        }
      }

      AppLogger.info('AuthRepository: Google sign in successful');
      return Right(user);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Google sign in failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Google sign in error', e, stackTrace);
      return Left(
        ServerFailure('Failed to sign in with Google: ${e.toString()}'),
      );
    }
  }

  /// Sign in with Apple
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      AppLogger.info('AuthRepository: Signing in with Apple');

      final authUser = await _authService.signInWithApple();

      // Try to get user from local cache
      User? user = await _getUserFromCache(authUser.id);

      if (user == null) {
        // Fetch from remote or create new
        user = await _fetchUserFromRemote(authUser.id);

        if (user == null) {
          final userModel = UserModel(
            id: authUser.id,
            email: authUser.email ?? '',
            displayName: authUser.displayName ?? 'User',
            photoUrl: authUser.photoUrl,
            isPremium: false,
            totalXp: 0,
            currentLevel: 1,
            streakShieldsRemaining: 0,
            vacationDaysRemaining: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _storageService.saveUser(userModel);
          await _storageService.syncUserToRemote(userModel);
          user = userModel.toEntity();
        }
      }

      AppLogger.info('AuthRepository: Apple sign in successful');
      return Right(user);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Apple sign in failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Apple sign in error', e, stackTrace);
      return Left(
        ServerFailure('Failed to sign in with Apple: ${e.toString()}'),
      );
    }
  }

  // ============================================================================
  // SIGN OUT
  // ============================================================================

  /// Sign out current user
  Future<Either<Failure, void>> signOut() async {
    try {
      AppLogger.info('AuthRepository: Signing out user');

      await _authService.signOut();

      // Clear local cache
      await _storageService.clearUserData();

      AppLogger.info('AuthRepository: User signed out successfully');
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Sign out failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Sign out error', e, stackTrace);
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  // ============================================================================
  // PASSWORD MANAGEMENT
  // ============================================================================

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.info('AuthRepository: Sending password reset email to: $email');

      await _authService.sendPasswordResetEmail(email);

      AppLogger.info('AuthRepository: Password reset email sent');
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Password reset failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Password reset error', e, stackTrace);
      return Left(ServerFailure('Failed to send reset email: ${e.toString()}'));
    }
  }

  /// Update password for current user
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      AppLogger.info('AuthRepository: Updating password');

      await _authService.updatePassword(newPassword);

      AppLogger.info('AuthRepository: Password updated successfully');
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Password update failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Password update error', e, stackTrace);
      return Left(ServerFailure('Failed to update password: ${e.toString()}'));
    }
  }

  // ============================================================================
  // PROFILE MANAGEMENT
  // ============================================================================

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      AppLogger.info('AuthRepository: Updating profile');

      // Update auth profile
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Get current user from cache
      final currentUser = await _authService.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('No authenticated user'));
      }

      // Update user in local storage
      final cachedUser = await _getUserFromCache(currentUser.id);
      if (cachedUser != null) {
        final updatedModel = UserModel.fromEntity(cachedUser).copyWith(
          displayName: displayName ?? cachedUser.displayName,
          photoUrl: photoUrl ?? cachedUser.photoUrl,
          updatedAt: DateTime.now(),
        );

        await _storageService.saveUser(updatedModel);
        await _storageService.syncUserToRemote(updatedModel);

        AppLogger.info('AuthRepository: Profile updated successfully');
        return Right(updatedModel.toEntity());
      }

      return Left(CacheFailure('User not found in cache'));
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Profile update failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Profile update error', e, stackTrace);
      return Left(ServerFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  // ============================================================================
  // SESSION MANAGEMENT
  // ============================================================================

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final authUser = await _authService.currentUser;

      if (authUser == null) {
        return Left(AuthFailure('No authenticated user'));
      }

      // Try to get from cache first
      final user = await _getUserFromCache(authUser.id);

      if (user != null) {
        return Right(user);
      }

      // Fetch from remote
      final remoteUser = await _fetchUserFromRemote(authUser.id);

      if (remoteUser != null) {
        return Right(remoteUser);
      }

      return Left(CacheFailure('User not found'));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Get current user error', e, stackTrace);
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  /// Refresh session
  Future<Either<Failure, void>> refreshSession() async {
    try {
      AppLogger.info('AuthRepository: Refreshing session');

      await _authService.refreshSession();

      AppLogger.info('AuthRepository: Session refreshed successfully');
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.error('AuthRepository: Session refresh failed', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('AuthRepository: Session refresh error', e, stackTrace);
      return Left(ServerFailure('Failed to refresh session: ${e.toString()}'));
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get user from local cache
  Future<User?> _getUserFromCache(String userId) async {
    try {
      final userModel = await _storageService.getUser(userId);
      return userModel?.toEntity();
    } catch (e) {
      AppLogger.warning('AuthRepository: Failed to get user from cache', e);
      return null;
    }
  }

  /// Fetch user from remote database
  Future<User?> _fetchUserFromRemote(String userId) async {
    try {
      final userModel = await _storageService.fetchUserFromRemote(userId);

      if (userModel != null) {
        // Save to cache
        await _storageService.saveUser(userModel);
        return userModel.toEntity();
      }

      return null;
    } catch (e) {
      AppLogger.warning('AuthRepository: Failed to fetch user from remote', e);
      return null;
    }
  }
}
