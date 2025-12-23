import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';

/// Application Logger
/// Production-ready logging with environment-based levels
///
/// Log Levels by Environment:
/// - Development: ALL (debug, info, warning, error, fatal)
/// - Staging: WARNING+ (warning, error, fatal)
/// - Production: ERROR+ (error, fatal only)

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls for errors
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
    level: _getLogLevel(),
  );

  /// Get log level based on environment
  static Level _getLogLevel() {
    if (EnvironmentConfig.isProduction) {
      return Level.error; // Only errors in production
    } else if (EnvironmentConfig.isStaging) {
      return Level.warning; // Warnings and errors in staging
    } else {
      return Level.debug; // Everything in development
    }
  }

  /// Debug log - Only shown in development
  /// Use for: Detailed debugging information
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Info log - Shown in development and staging
  /// Use for: General informational messages
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning log - Shown in all environments
  /// Use for: Warning messages, recoverable errors
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error log - Shown in all environments + sent to Crashlytics
  /// Use for: Error messages, exceptions
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Fatal log - Critical errors
  /// Use for: Fatal errors that crash the app
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log with custom level
  static void log(
    Level level,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    switch (level) {
      case Level.debug:
        debug(message, error, stackTrace);
        break;
      case Level.info:
        info(message, error, stackTrace);
        break;
      case Level.warning:
        warning(message, error, stackTrace);
        break;
      case Level.error:
        error(message, error, stackTrace);
        break;
      case Level.fatal:
        fatal(message, error, stackTrace);
        break;
      default:
        info(message, error, stackTrace);
    }
  }

  /// Sanitize sensitive data before logging
  static String sanitize(String input, {int visibleChars = 4}) {
    if (input.length <= visibleChars) {
      return '***';
    }
    return '${input.substring(0, visibleChars)}***';
  }

  /// Log with sanitized data
  static void debugSanitized(String message, String sensitiveData) {
    debug('$message: ${sanitize(sensitiveData)}');
  }
}

/// Service-specific loggers for better organization
class AuthLogger {
  static void signUpAttempt(String email) {
    AppLogger.debug('Sign up attempt for: $email');
  }

  static void signUpSuccess(String userId) {
    AppLogger.info('User signed up successfully: $userId');
  }

  static void signUpFailed(String email, dynamic error) {
    AppLogger.warning('Sign up failed for: $email', error);
  }

  static void signInAttempt(String email) {
    AppLogger.debug('Sign in attempt for: $email');
  }

  static void signInSuccess(String userId) {
    AppLogger.info('User signed in successfully: $userId');
  }

  static void signInFailed(String email, dynamic error) {
    AppLogger.warning('Sign in failed for: $email', error);
  }

  static void signOut(String userId) {
    AppLogger.info('User signed out: $userId');
  }

  static void passwordResetRequested(String email) {
    AppLogger.info('Password reset requested for: $email');
  }

  static void sessionRefreshed() {
    AppLogger.debug('Session refreshed successfully');
  }

  static void sessionExpired() {
    AppLogger.warning('Session expired');
  }
}

class AnalyticsLogger {
  static void eventTracked(String eventName) {
    AppLogger.debug('Analytics event tracked: $eventName');
  }

  static void userPropertySet(String propertyName, String value) {
    AppLogger.debug('User property set: $propertyName = $value');
  }

  static void trackingFailed(String eventName, dynamic error) {
    AppLogger.warning('Failed to track event: $eventName', error);
  }
}

class AdLogger {
  static void initialized() {
    AppLogger.info('AdMob initialized successfully');
  }

  static void initializationFailed(dynamic error) {
    AppLogger.error('AdMob initialization failed', error);
  }

  static void adLoaded(String adType) {
    AppLogger.debug('Ad loaded: $adType');
  }

  static void adFailedToLoad(String adType, dynamic error) {
    AppLogger.warning('Ad failed to load: $adType', error);
  }

  static void adShown(String adType) {
    AppLogger.info('Ad shown: $adType');
  }

  static void adClicked(String adType) {
    AppLogger.info('Ad clicked: $adType');
  }

  static void rewardEarned(int xpAmount) {
    AppLogger.info('Reward earned from ad: $xpAmount XP');
  }

  static void premiumUserSkipped() {
    AppLogger.debug('Premium user - ads disabled');
  }
}

class NotificationLogger {
  static void initialized() {
    AppLogger.info('Notification service initialized');
  }

  static void initializationFailed(dynamic error) {
    AppLogger.error('Notification initialization failed', error);
  }

  static void permissionGranted() {
    AppLogger.info('Notification permissions granted');
  }

  static void permissionDenied() {
    AppLogger.warning('Notification permissions denied');
  }

  static void fcmTokenReceived(String token) {
    AppLogger.debug(
      'FCM token received: ${AppLogger.sanitize(token, visibleChars: 8)}',
    );
  }

  static void notificationScheduled(String habitName, DateTime time) {
    AppLogger.debug('Notification scheduled: $habitName at $time');
  }

  static void notificationShown(String title) {
    AppLogger.debug('Notification shown: $title');
  }

  static void messageReceived(String messageId) {
    AppLogger.debug('Push message received: $messageId');
  }

  static void messageOpened(String messageId) {
    AppLogger.info('Push message opened: $messageId');
  }
}

class IAPLogger {
  static void initialized() {
    AppLogger.info('IAP service initialized');
  }

  static void initializationFailed(dynamic error) {
    AppLogger.error('IAP initialization failed', error);
  }

  static void productsLoaded(int count) {
    AppLogger.debug('Products loaded: $count');
  }

  static void productsFailed(dynamic error) {
    AppLogger.error('Failed to load products', error);
  }

  static void purchaseStarted(String productId) {
    AppLogger.info('Purchase started: $productId');
  }

  static void purchaseCompleted(String productId, String transactionId) {
    AppLogger.info('Purchase completed: $productId (txn: $transactionId)');
  }

  static void purchaseFailed(String productId, dynamic error) {
    AppLogger.warning('Purchase failed: $productId', error);
  }

  static void purchaseCancelled(String productId) {
    AppLogger.info('Purchase cancelled by user: $productId');
  }

  static void restoreStarted() {
    AppLogger.info('Restore purchases started');
  }

  static void restoreCompleted(bool hasActiveSubscription) {
    AppLogger.info(
      'Restore completed. Active subscription: $hasActiveSubscription',
    );
  }

  static void restoreFailed(dynamic error) {
    AppLogger.error('Restore purchases failed', error);
  }
}
