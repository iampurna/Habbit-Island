import 'package:equatable/equatable.dart';

/// Auth Events
/// User actions that trigger authentication state changes

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// AUTHENTICATION EVENTS
// ============================================================================

/// Sign up with email and password
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Sign in with email and password
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Sign in with Google
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Sign in with Apple
class AppleSignInRequested extends AuthEvent {
  const AppleSignInRequested();
}

/// Sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

// ============================================================================
// PASSWORD MANAGEMENT
// ============================================================================

/// Send password reset email
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object> get props => [email];
}

/// Update password
class PasswordUpdateRequested extends AuthEvent {
  final String newPassword;

  const PasswordUpdateRequested(this.newPassword);

  @override
  List<Object> get props => [newPassword];
}

// ============================================================================
// PROFILE MANAGEMENT
// ============================================================================

/// Update user profile
class ProfileUpdateRequested extends AuthEvent {
  final String? displayName;
  final String? photoUrl;

  const ProfileUpdateRequested({this.displayName, this.photoUrl});

  @override
  List<Object?> get props => [displayName, photoUrl];
}

// ============================================================================
// SESSION MANAGEMENT
// ============================================================================

/// Check authentication state
class AuthStateChecked extends AuthEvent {
  const AuthStateChecked();
}

/// Refresh session
class SessionRefreshRequested extends AuthEvent {
  const SessionRefreshRequested();
}
