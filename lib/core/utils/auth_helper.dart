import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../domain/entities/user.dart';

/// Auth Helper
/// Provides utility methods for authentication across the app
class AuthHelper {
  /// Get current authenticated user ID
  /// Returns null if user is not authenticated
  static String? getCurrentUserId(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState is Authenticated) {
        return authState.user.id;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current authenticated user ID or throw exception
  /// Use this when user MUST be authenticated for the operation
  static String getCurrentUserIdOrThrow(BuildContext context) {
    final userId = getCurrentUserId(context);

    if (userId == null) {
      throw UnauthorizedException('User must be authenticated');
    }

    return userId;
  }

  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;
      return authState is Authenticated;
    } catch (e) {
      return false;
    }
  }

  /// Get current user or null
  static User? getCurrentUser(BuildContext context) {
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState is Authenticated) {
        return authState.user;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Navigate to login if not authenticated
  static void requireAuth(
    BuildContext context, {
    VoidCallback? onNotAuthenticated,
  }) {
    if (!isAuthenticated(context)) {
      if (onNotAuthenticated != null) {
        onNotAuthenticated();
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}

/// Custom exception for unauthorized access
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}
