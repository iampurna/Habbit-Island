import 'package:bloc/bloc.dart';
import 'package:habbit_island/data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/utils/app_logger.dart';

/// Auth BLoC - Manages authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordUpdateRequested>(_onPasswordUpdateRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthStateChecked>(_onAuthStateChecked);
    on<SessionRefreshRequested>(_onSessionRefreshRequested);
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Creating account...'));

      final user = await _authService.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      AppLogger.info('AuthBloc: Sign up successful');
      emit(Authenticated(user));
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Sign up failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in...'));

      final user = await _authService.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      AppLogger.info('AuthBloc: Sign in successful');
      emit(Authenticated(user));
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Sign in failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in with Google...'));
      await _authService.signInWithGoogle();
      // Auth state will be updated via stream
      AppLogger.info('AuthBloc: Google sign in initiated');
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Google sign in failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAppleSignInRequested(
    AppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in with Apple...'));
      await _authService.signInWithApple();
      // Auth state will be updated via stream
      AppLogger.info('AuthBloc: Apple sign in initiated');
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Apple sign in failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing out...'));
      await _authService.signOut();
      AppLogger.info('AuthBloc: Sign out successful');
      emit(Unauthenticated());
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Sign out failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Sending reset email...'));
      await _authService.sendPasswordResetEmail(event.email);
      AppLogger.info('AuthBloc: Password reset email sent');
      emit(const AuthSuccess('Password reset email sent'));
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Password reset failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordUpdateRequested(
    PasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Updating password...'));
      await _authService.updatePassword(event.newPassword);
      AppLogger.info('AuthBloc: Password updated');
      emit(const AuthSuccess('Password updated successfully'));
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Password update failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Updating profile...'));
      await _authService.updateProfile(
        displayName: event.displayName,
        photoUrl: event.photoUrl,
      );
      AppLogger.info('AuthBloc: Profile updated');
      emit(const AuthSuccess('Profile updated successfully'));
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Profile update failed', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthStateChecked(
    AuthStateChecked event,
    Emitter<AuthState> emit,
  ) async {
    final isAuth = _authService.isAuthenticated;
    if (isAuth) {
      emit(const AuthLoading(message: 'Checking auth...'));
      // Fetch current user
      AppLogger.debug('AuthBloc: User is authenticated');
    } else {
      AppLogger.debug('AuthBloc: User is not authenticated');
      emit(Unauthenticated());
    }
  }

  Future<void> _onSessionRefreshRequested(
    SessionRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.refreshSession();
      AppLogger.debug('AuthBloc: Session refreshed');
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Session refresh failed', e, stackTrace);
      emit(Unauthenticated());
    }
  }
}
