import 'package:flutter/foundation.dart';
import 'dart:io';
import 'environment.dart';
import 'supabase_config.dart';
import 'firebase_config.dart';

/// Application Configuration
/// Master configuration for Habit Island app
/// Centralizes all app settings, API keys, and feature flags

class AppConfig {
  // ============================================================================
  // APP INFORMATION
  // ============================================================================

  static const String appName = 'Habit Island';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  /// Get app name with environment suffix
  static String get fullAppName =>
      '$appName${EnvironmentConfig.environmentSuffix}';

  /// App bundle/package identifier
  static String get bundleId {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return 'com.habitisland.dev';
      case Environment.staging:
        return 'com.habitisland.staging';
      case Environment.production:
        return 'com.habitisland';
    }
  }

  // ============================================================================
  // API ENDPOINTS
  // ============================================================================

  /// Supabase configuration
  static String get supabaseUrl => SupabaseConfig.url;
  static String get supabaseAnonKey => SupabaseConfig.anonKey;

  /// Firebase configuration
  static String get firebaseProjectId => FirebaseConfig.projectId;
  static String get firebaseAppId => FirebaseConfig.appId;
  static String get firebaseApiKey => FirebaseConfig.apiKey;

  /// API base URL (if you have custom backend)
  static String get apiBaseUrl {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.habitisland.com/api/v1';
      case Environment.production:
        return 'https://api.habitisland.com/api/v1';
    }
  }

  // ============================================================================
  // THIRD-PARTY API KEYS
  // ============================================================================

  /// RevenueCat API keys
  static String get revenueCatAndroidKey {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return 'YOUR_DEV_ANDROID_KEY';
      case Environment.staging:
        return 'YOUR_STAGING_ANDROID_KEY';
      case Environment.production:
        return 'YOUR_PROD_ANDROID_KEY';
    }
  }

  static String get revenueCatIosKey {
    switch (EnvironmentConfig.current) {
      case Environment.development:
        return 'YOUR_DEV_IOS_KEY';
      case Environment.staging:
        return 'YOUR_STAGING_IOS_KEY';
      case Environment.production:
        return 'YOUR_PROD_IOS_KEY';
    }
  }

  /// AdMob Ad Unit IDs
  static String get adMobBannerId {
    if (Platform.isAndroid) {
      return EnvironmentConfig.isProduction
          ? 'ca-app-pub-XXXXX/BANNER'
          : 'ca-app-pub-3940256099942544/6300978111'; // Test
    } else {
      return EnvironmentConfig.isProduction
          ? 'ca-app-pub-XXXXX/BANNER'
          : 'ca-app-pub-3940256099942544/2934735716'; // Test
    }
  }

  static String get adMobInterstitialId {
    if (Platform.isAndroid) {
      return EnvironmentConfig.isProduction
          ? 'ca-app-pub-XXXXX/INTERSTITIAL'
          : 'ca-app-pub-3940256099942544/1033173712'; // Test
    } else {
      return EnvironmentConfig.isProduction
          ? 'ca-app-pub-XXXXX/INTERSTITIAL'
          : 'ca-app-pub-3940256099942544/4411468910'; // Test
    }
  }

  static String get adMobRewardedId {
    if (Platform.isAndroid) {
      return EnvironmentConfig.isProduction
          ? 'ca-app-pub-XXXXX/REWARDED'
          : 'ca-app-pub-3940256099942544/5224354917'; // Test
    } else {
      return EnvironmentConfig.isProduction
          ? 'ca-app-pub-XXXXX/REWARDED'
          : 'ca-app-pub-3940256099942544/1712485313'; // Test
    }
  }

  // ============================================================================
  // FEATURE FLAGS
  // ============================================================================

  /// Enable/disable analytics
  static bool get analyticsEnabled =>
      EnvironmentConfig.isProduction || EnvironmentConfig.isStaging;

  /// Enable/disable crash reporting
  static bool get crashReportingEnabled =>
      EnvironmentConfig.isProduction || EnvironmentConfig.isStaging;

  /// Enable/disable ads
  static bool get adsEnabled => EnvironmentConfig.isProduction;

  /// Enable debug logging
  static bool get debugLogging => !EnvironmentConfig.isProduction;

  /// Enable performance monitoring
  static bool get performanceMonitoring => EnvironmentConfig.isProduction;

  /// Show environment banner (dev/staging)
  static bool get showEnvironmentBanner => !EnvironmentConfig.isProduction;

  // ============================================================================
  // APP SETTINGS
  // ============================================================================

  /// Maximum habits for free tier
  static const int maxFreeHabits = 7;

  /// Maximum habits for premium tier
  static const int maxPremiumHabits = 999;

  /// XP per level
  static const int xpPerLevel = 100;

  /// Base XP for habit completion
  static const int baseHabitXp = 10;

  /// Bonus XP for all daily complete
  static const int allDailyBonusXp = 50;

  /// Milestone XP
  static const int sevenDayMilestoneXp = 100;
  static const int thirtyDayMilestoneXp = 500;

  /// Rewarded ad XP
  static const int rewardedAdXp = 50;

  /// Daily login XP
  static const int dailyLoginXp = 5;

  /// Max rewarded ads per day
  static const int maxRewardedAdsPerDay = 3;

  /// Streak shields per month (premium)
  static const int streakShieldsPerMonth = 3;

  /// Vacation days per year (premium)
  static const int vacationDaysPerYear = 30;

  /// Grace period for completions (hours after midnight)
  static const int gracePeriodHours = 3;

  /// Sync interval (minutes)
  static const int syncIntervalMinutes = 15;

  /// Session timeout (minutes)
  static const int sessionTimeoutMinutes = 30;

  // ============================================================================
  // PREMIUM PRICING
  // ============================================================================

  /// Premium prices (USD)
  static const double monthlyPrice = 4.99;
  static const double annualPrice = 39.99;
  static const double lifetimePrice = 49.99;

  /// Product IDs
  static const String monthlyProductId = 'premium_monthly';
  static const String annualProductId = 'premium_annual';
  static const String lifetimeProductId = 'premium_lifetime';

  // ============================================================================
  // TIMEOUTS & LIMITS
  // ============================================================================

  /// API timeout (seconds)
  static const int apiTimeout = 30;

  /// Cache duration (hours)
  static const int cacheDuration = 24;

  /// Max retry attempts for failed operations
  static const int maxRetryAttempts = 3;

  /// Retry delay (seconds)
  static const int retryDelay = 5;

  /// Max sync queue size
  static const int maxSyncQueueSize = 1000;

  // ============================================================================
  // URLS
  // ============================================================================

  /// Website URL
  static const String websiteUrl = 'https://habitisland.com';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://habitisland.com/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://habitisland.com/terms';

  /// Support email
  static const String supportEmail = 'support@habitisland.com';

  /// App store URLs
  static const String appStoreUrl =
      'https://apps.apple.com/app/habit-island/id123456789';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.habitisland';

  // ============================================================================
  // SOCIAL MEDIA
  // ============================================================================

  static const String twitterUrl = 'https://twitter.com/habitisland';
  static const String instagramUrl = 'https://instagram.com/habitisland';
  static const String facebookUrl = 'https://facebook.com/habitisland';

  // ============================================================================
  // PLATFORM-SPECIFIC
  // ============================================================================

  /// Check if running on mobile
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Check if running on desktop
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// Check if running on web
  static bool get isWeb => kIsWeb;

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate configuration
  static bool validate() {
    try {
      // Check Supabase config
      assert(supabaseUrl.isNotEmpty, 'Supabase URL is empty');
      assert(supabaseAnonKey.isNotEmpty, 'Supabase anon key is empty');

      // Check Firebase config (if applicable)
      if (analyticsEnabled || crashReportingEnabled) {
        assert(firebaseProjectId.isNotEmpty, 'Firebase project ID is empty');
        assert(firebaseApiKey.isNotEmpty, 'Firebase API key is empty');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Configuration validation failed: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // DEBUG HELPERS
  // ============================================================================

  /// Print configuration summary
  static void printConfig() {
    if (!kDebugMode) return;

    print('═' * 60);
    print('HABIT ISLAND CONFIGURATION');
    print('═' * 60);
    print('Environment: ${EnvironmentConfig.environmentName}');
    print('App Name: $fullAppName');
    print('Version: $appVersion ($buildNumber)');
    print('Bundle ID: $bundleId');
    print('─' * 60);
    print('Supabase URL: $supabaseUrl');
    print('Firebase Project: $firebaseProjectId');
    print('API Base URL: $apiBaseUrl');
    print('─' * 60);
    print('Analytics: ${analyticsEnabled ? 'Enabled' : 'Disabled'}');
    print('Crash Reporting: ${crashReportingEnabled ? 'Enabled' : 'Disabled'}');
    print('Ads: ${adsEnabled ? 'Enabled' : 'Disabled'}');
    print('Debug Logging: ${debugLogging ? 'Enabled' : 'Disabled'}');
    print('═' * 60);
  }
}
