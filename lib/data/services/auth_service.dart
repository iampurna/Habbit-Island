import 'package:habbit_island/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data_sources/remote/supabase_client.dart';
import '../models/user_model.dart';

/// Authentication Service
/// Handles all authentication operations using Supabase Auth
/// Reference: Technical Specification Addendum §5 (Authentication)

class AuthService {
  final SupabaseClientManager _supabaseManager;

  AuthService({SupabaseClientManager? supabaseManager})
    : _supabaseManager = supabaseManager ?? SupabaseClientManager();

  SupabaseClient get _client => _supabaseManager.client;

  // ============================================================================
  // AUTHENTICATION STATE
  // ============================================================================

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Get current user email
  String? get currentUserEmail => currentUser?.email;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================================================
  // EMAIL AUTHENTICATION
  // ============================================================================

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AuthLogger.signUpAttempt(email);

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName ?? email.split('@').first},
      );

      if (response.user == null) {
        AppLogger.warning('Sign up failed - no user returned for: $email');
        throw AuthException('Sign up failed - no user returned');
      }

      // Create user model
      final user = UserModel(
        id: response.user!.id,
        email: email,
        displayName: displayName ?? email.split('@').first,
        photoUrl: response.user!.userMetadata?['avatar_url'] as String?,
        isPremium: false,
        premiumTier: PremiumTier.free,
        totalXp: 0,
        currentLevel: 1,
        totalHabits: 0,
        activeHabits: 0,
        totalCompletions: 0,
        longestStreak: 0,
        currentGlobalStreak: 0,
        currentIslandId: '', // Will be set after island creation
        unlockedZoneIds: ['starter-beach'], // Default zone
        streakShieldsRemaining: 0,
        vacationDaysRemaining: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AuthLogger.signUpSuccess(user.id);
      return user;
    } on AuthException catch (e) {
      AuthLogger.signUpFailed(email, e);
      throw AuthException('Sign up failed: ${e.message}');
    } catch (e, stackTrace) {
      AuthLogger.signUpFailed(email, e);
      AppLogger.error('Unexpected sign up error', e, stackTrace);
      throw AuthException('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AuthLogger.signInAttempt(email);

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        AppLogger.warning('Sign in failed - no user returned for: $email');
        throw AuthException('Sign in failed - no user returned');
      }

      final user = UserModel(
        id: response.user!.id,
        email: email,
        displayName:
            response.user!.userMetadata?['display_name'] as String? ??
            email.split('@').first,
        photoUrl: response.user!.userMetadata?['avatar_url'] as String?,
        isPremium: false,
        premiumTier: PremiumTier.free,
        totalXp: 0,
        currentLevel: 1,
        totalHabits: 0,
        activeHabits: 0,
        totalCompletions: 0,
        longestStreak: 0,
        currentGlobalStreak: 0,
        currentIslandId: '',
        unlockedZoneIds: ['starter-beach'],
        streakShieldsRemaining: 0,
        vacationDaysRemaining: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      AuthLogger.signInSuccess(user.id);
      return user;
    } on AuthException catch (e) {
      AuthLogger.signInFailed(email, e);
      if (e.message.contains('Invalid login credentials')) {
        throw InvalidCredentialsException();
      }
      throw AuthException('Sign in failed: ${e.message}');
    } catch (e, stackTrace) {
      AuthLogger.signInFailed(email, e);
      AppLogger.error('Unexpected sign in error', e, stackTrace);
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final userId = currentUserId;
      await _client.auth.signOut();

      if (userId != null) {
        AuthLogger.signOut(userId);
      } else {
        AppLogger.debug('Sign out completed (no user ID)');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      throw AuthException('Sign out failed: $e');
    }
  }

  // ============================================================================
  // SOCIAL AUTHENTICATION
  // ============================================================================

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      AppLogger.debug('Initiating Google sign in...');

      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'habitisland://login-callback',
      );

      AppLogger.info('Google sign in initiated successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Google sign in failed', e, stackTrace);
      throw AuthException('Google sign in failed: $e');
    }
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      AppLogger.debug('Initiating Apple sign in...');

      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'habitisland://login-callback',
      );

      AppLogger.info('Apple sign in initiated successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Apple sign in failed', e, stackTrace);
      throw AuthException('Apple sign in failed: $e');
    }
  }

  // ============================================================================
  // PASSWORD MANAGEMENT
  // ============================================================================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.debug('Sending password reset email to: $email');

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'habitisland://reset-password',
      );

      AuthLogger.passwordResetRequested(email);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send password reset email', e, stackTrace);
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  /// Update password (user must be authenticated)
  Future<void> updatePassword(String newPassword) async {
    try {
      if (!isAuthenticated) {
        AppLogger.warning('Attempted password update without authentication');
        throw AuthException('User must be authenticated to update password');
      }

      AppLogger.debug('Updating password for user: $currentUserId');

      await _client.auth.updateUser(UserAttributes(password: newPassword));

      AppLogger.info('Password updated successfully for: $currentUserId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update password', e, stackTrace);
      throw AuthException('Failed to update password: $e');
    }
  }

  // ============================================================================
  // EMAIL VERIFICATION
  // ============================================================================

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (!isAuthenticated) {
        AppLogger.warning(
          'Attempted email verification without authentication',
        );
        throw AuthException('User must be authenticated');
      }

      final email = currentUserEmail;
      if (email == null) {
        AppLogger.warning('No email found for current user');
        throw AuthException('No email found for current user');
      }

      AppLogger.debug('Resending email verification to: $email');

      await _client.auth.resend(type: OtpType.signup, email: email);

      AppLogger.info('Email verification sent to: $email');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send email verification', e, stackTrace);
      throw AuthException('Failed to send email verification: $e');
    }
  }

  /// Check if email is verified
  bool get isEmailVerified {
    return currentUser?.emailConfirmedAt != null;
  }

  // ============================================================================
  // ACCOUNT MANAGEMENT
  // ============================================================================

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      if (!isAuthenticated) {
        AppLogger.warning('Attempted profile update without authentication');
        throw AuthException('User must be authenticated');
      }

      AppLogger.debug('Updating profile for user: $currentUserId');

      await _client.auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'display_name': displayName,
            if (photoUrl != null) 'avatar_url': photoUrl,
          },
        ),
      );

      AppLogger.info('Profile updated successfully for: $currentUserId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update profile', e, stackTrace);
      throw AuthException('Failed to update profile: $e');
    }
  }

  /// Delete account (requires password confirmation in production)
  Future<void> deleteAccount() async {
    try {
      if (!isAuthenticated) {
        AppLogger.warning('Attempted account deletion without authentication');
        throw AuthException('User must be authenticated');
      }

      final userId = currentUserId;
      AppLogger.warning('Deleting account for user: $userId');

      await _client.rpc('delete_user_account');

      AppLogger.info('Account deleted successfully: $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete account', e, stackTrace);
      throw AuthException('Failed to delete account: $e');
    }
  }

  // ============================================================================
  // SESSION MANAGEMENT
  // ============================================================================

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      AppLogger.debug('Refreshing session for user: $currentUserId');
      await _client.auth.refreshSession();
      AuthLogger.sessionRefreshed();
    } catch (e, stackTrace) {
      AuthLogger.sessionExpired();
      AppLogger.error('Failed to refresh session', e, stackTrace);
      throw AuthException('Failed to refresh session: $e');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final session = _client.auth.currentSession;
      final token = session?.accessToken;

      if (token != null) {
        AppLogger.debug('Access token retrieved for user: $currentUserId');
      } else {
        AppLogger.warning('No access token available');
      }

      return token;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get access token', e, stackTrace);
      throw AuthException('Failed to get access token: $e');
    }
  }

  /// Check if session is valid
  bool get hasValidSession {
    final session = _client.auth.currentSession;
    if (session == null) return false;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    return DateTime.now().millisecondsSinceEpoch < expiresAt * 1000;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  /// Requirements: Min 8 chars, 1 uppercase, 1 lowercase, 1 number
  bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  /// Get password strength (0-4)
  int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')))
      strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength.clamp(0, 4);
  }
}

/// Custom auth exceptions
class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class EmailAlreadyExistsException extends AuthException {
  EmailAlreadyExistsException() : super('Email already exists');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException()
    : super(
        'Password must be at least 8 characters with uppercase, lowercase, and number',
      );
}
