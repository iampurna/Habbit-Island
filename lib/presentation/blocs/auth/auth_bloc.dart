import 'package:bloc/bloc.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/utils/app_logger.dart';

/// Auth BLoC - Manages authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthService authService,
    required AuthRepository authRepository,
  }) : _authService = authService,
       _authRepository = authRepository,
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

      final result = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Sign up failed', failure);
          emit(AuthError(failure.message));
        },
        (user) {
          AppLogger.info('AuthBloc: Sign up successful');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Sign up error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in...'));

      final result = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Sign in failed', failure);
          emit(AuthError(failure.message));
        },
        (user) {
          AppLogger.info('AuthBloc: Sign in successful');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Sign in error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in with Google...'));

      final result = await _authRepository.signInWithGoogle();

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Google sign in failed', failure);
          emit(AuthError(failure.message));
        },
        (user) {
          AppLogger.info('AuthBloc: Google sign in successful');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Google sign in error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAppleSignInRequested(
    AppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing in with Apple...'));

      final result = await _authRepository.signInWithApple();

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Apple sign in failed', failure);
          emit(AuthError(failure.message));
        },
        (user) {
          AppLogger.info('AuthBloc: Apple sign in successful');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Apple sign in error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Signing out...'));

      final result = await _authRepository.signOut();

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Sign out failed', failure);
          emit(AuthError(failure.message));
        },
        (_) {
          AppLogger.info('AuthBloc: Sign out successful');
          emit(Unauthenticated());
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Sign out error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Sending reset email...'));

      final result = await _authRepository.sendPasswordResetEmail(event.email);

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Password reset failed', failure);
          emit(AuthError(failure.message));
        },
        (_) {
          AppLogger.info('AuthBloc: Password reset email sent');
          emit(const AuthSuccess('Password reset email sent'));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Password reset error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordUpdateRequested(
    PasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Updating password...'));

      final result = await _authRepository.updatePassword(event.newPassword);

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Password update failed', failure);
          emit(AuthError(failure.message));
        },
        (_) {
          AppLogger.info('AuthBloc: Password updated');
          emit(const AuthSuccess('Password updated successfully'));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Password update error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading(message: 'Updating profile...'));

      final result = await _authRepository.updateProfile(
        displayName: event.displayName,
        photoUrl: event.photoUrl,
      );

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Profile update failed', failure);
          emit(AuthError(failure.message));
        },
        (user) {
          AppLogger.info('AuthBloc: Profile updated');
          emit(const AuthSuccess('Profile updated successfully'));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Profile update error', e, stackTrace);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthStateChecked(
    AuthStateChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _authRepository.getCurrentUser();

      result.fold(
        (failure) {
          AppLogger.debug('AuthBloc: User is not authenticated');
          emit(Unauthenticated());
        },
        (user) {
          AppLogger.debug('AuthBloc: User is authenticated');
          emit(Authenticated(user));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Auth state check error', e, stackTrace);
      emit(Unauthenticated());
    }
  }

  Future<void> _onSessionRefreshRequested(
    SessionRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _authRepository.refreshSession();

      result.fold(
        (failure) {
          AppLogger.error('AuthBloc: Session refresh failed', failure);
          emit(Unauthenticated());
        },
        (_) {
          AppLogger.debug('AuthBloc: Session refreshed');
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('AuthBloc: Session refresh error', e, stackTrace);
      emit(Unauthenticated());
    }
  }
}
