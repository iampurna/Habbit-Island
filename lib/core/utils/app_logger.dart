import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import '../../config/environment.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      // ignore: deprecated_member_use
      printTime: true,
    ),
    level: _getLogLevel(),
  );

  /// Get log level based on environment
  static Level _getLogLevel() {
    if (EnvironmentConfig.isProduction) {
      return Level.error; // Only errors in production
    } else if (EnvironmentConfig.isStaging) {
      return Level.warning; // Warnings+ in staging
    } else {
      return Level.debug; // Everything in development
    }
  }

  /// Debug log (only in development)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info log
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning log
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error log (always logged + sent to Crashlytics)
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Send to Firebase Crashlytics in production
    if (EnvironmentConfig.isProduction) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
      );
    }
  }

  /// Fatal error (crashes app in debug, logs in production)
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    if (EnvironmentConfig.isProduction) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: true,
      );
    }
  }
}
