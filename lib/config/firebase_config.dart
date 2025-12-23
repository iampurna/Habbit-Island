import 'dart:io';
import 'environment.dart';

/// Firebase Configuration
/// Manages Firebase credentials and settings per environment
/// Note: Firebase config is typically managed via google-services.json (Android)
/// and GoogleService-Info.plist (iOS), but this provides programmatic access

class FirebaseConfig {
  // ============================================================================
  // ANDROID CONFIGURATION
  // ============================================================================

  // Development
  static const String _androidDevProjectId = 'habit-island-dev';
  static const String _androidDevAppId = '1:123456789:android:abcdef';
  static const String _androidDevApiKey = 'AIzaSyDev...';
  static const String _androidDevMessagingSenderId = '123456789';

  // Staging
  static const String _androidStagingProjectId = 'habit-island-staging';
  static const String _androidStagingAppId = '1:987654321:android:fedcba';
  static const String _androidStagingApiKey = 'AIzaSyStaging...';
  static const String _androidStagingMessagingSenderId = '987654321';

  // Production
  static const String _androidProdProjectId = 'habit-island-prod';
  static const String _androidProdAppId = '1:111222333:android:xyz123';
  static const String _androidProdApiKey = 'AIzaSyProd...';
  static const String _androidProdMessagingSenderId = '111222333';

  // ============================================================================
  // iOS CONFIGURATION
  // ============================================================================

  // Development
  static const String _iosDevProjectId = 'habit-island-dev';
  static const String _iosDevAppId = '1:123456789:ios:abcdef';
  static const String _iosDevApiKey = 'AIzaSyDev...';
  static const String _iosDevMessagingSenderId = '123456789';
  static const String _iosDevClientId = 'com.googleusercontent.apps.123-dev';
  static const String _iosDevBundleId = 'com.habitisland.dev';

  // Staging
  static const String _iosStagingProjectId = 'habit-island-staging';
  static const String _iosStagingAppId = '1:987654321:ios:fedcba';
  static const String _iosStagingApiKey = 'AIzaSyStaging...';
  static const String _iosStagingMessagingSenderId = '987654321';
  static const String _iosStagingClientId =
      'com.googleusercontent.apps.987-staging';
  static const String _iosStagingBundleId = 'com.habitisland.staging';

  // Production
  static const String _iosProdProjectId = 'habit-island-prod';
  static const String _iosProdAppId = '1:111222333:ios:xyz123';
  static const String _iosProdApiKey = 'AIzaSyProd...';
  static const String _iosProdMessagingSenderId = '111222333';
  static const String _iosProdClientId = 'com.googleusercontent.apps.111-prod';
  static const String _iosProdBundleId = 'com.habitisland';

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Get project ID
  static String get projectId {
    if (Platform.isAndroid) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _androidDevProjectId;
        case Environment.staging:
          return _androidStagingProjectId;
        case Environment.production:
          return _androidProdProjectId;
      }
    } else if (Platform.isIOS) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _iosDevProjectId;
        case Environment.staging:
          return _iosStagingProjectId;
        case Environment.production:
          return _iosProdProjectId;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get app ID
  static String get appId {
    if (Platform.isAndroid) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _androidDevAppId;
        case Environment.staging:
          return _androidStagingAppId;
        case Environment.production:
          return _androidProdAppId;
      }
    } else if (Platform.isIOS) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _iosDevAppId;
        case Environment.staging:
          return _iosStagingAppId;
        case Environment.production:
          return _iosProdAppId;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get API key
  static String get apiKey {
    if (Platform.isAndroid) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _androidDevApiKey;
        case Environment.staging:
          return _androidStagingApiKey;
        case Environment.production:
          return _androidProdApiKey;
      }
    } else if (Platform.isIOS) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _iosDevApiKey;
        case Environment.staging:
          return _iosStagingApiKey;
        case Environment.production:
          return _iosProdApiKey;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get messaging sender ID
  static String get messagingSenderId {
    if (Platform.isAndroid) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _androidDevMessagingSenderId;
        case Environment.staging:
          return _androidStagingMessagingSenderId;
        case Environment.production:
          return _androidProdMessagingSenderId;
      }
    } else if (Platform.isIOS) {
      switch (EnvironmentConfig.current) {
        case Environment.development:
          return _iosDevMessagingSenderId;
        case Environment.staging:
          return _iosStagingMessagingSenderId;
        case Environment.production:
          return _iosProdMessagingSenderId;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get iOS client ID
  static String get iosClientId {
    if (!Platform.isIOS) {
      throw UnsupportedError('iOS client ID only available on iOS');
    }
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return _iosDevClientId;
      case Environment.staging:
        return _iosStagingClientId;
      case Environment.production:
        return _iosProdClientId;
    }
  }

  /// Get iOS bundle ID
  static String get iosBundleId {
    if (!Platform.isIOS) {
      throw UnsupportedError('iOS bundle ID only available on iOS');
    }
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return _iosDevBundleId;
      case Environment.staging:
        return _iosStagingBundleId;
      case Environment.production:
        return _iosProdBundleId;
    }
  }
}
