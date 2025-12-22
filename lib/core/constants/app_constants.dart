/// Habit Island Core Application Constants
/// This file contains all game mechanics constants, limits, and configuration values.
/// These values are the foundation of the app's business logic.
library;

class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ============================================================================
  // APP METADATA
  // ============================================================================

  static const String appName = 'Habit Island';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ============================================================================
  // XP SYSTEM
  // ============================================================================

  /// XP earned for completing any single habit
  static const int xpPerHabitCompletion = 10;

  /// Bonus XP for completing ALL daily habits in a single day
  static const int xpBonusAllDailyComplete = 50;

  /// Milestone XP for maintaining a 7-day streak
  static const int xpBonus7DayStreak = 100;

  /// Milestone XP for maintaining a 30-day streak
  static const int xpBonus30DayStreak = 500;

  /// XP for daily login (engagement reward)
  static const int xpDailyLogin = 5;

  /// XP earned for watching a rewarded ad
  static const int xpRewardedAd = 50;

  // ============================================================================
  // HABIT LIMITS
  // ============================================================================

  /// Maximum active habits for free tier users
  static const int maxHabitsFree = 7;

  /// Maximum active habits for premium users (unlimited in practice)
  static const int maxHabitsPremium = 999;

  /// Minimum habit name length
  static const int habitNameMinLength = 2;

  /// Maximum habit name length
  static const int habitNameMaxLength = 50;

  /// Maximum habits that can be placed in Starter Beach zone
  static const int maxHabitsStarterBeach = 4;

  /// Maximum habits that can be placed in Forest Grove zone
  static const int maxHabitsForestGrove = 7;

  /// Maximum habits that can be placed in Mountain Ridge zone (Post-MVP)
  static const int maxHabitsMountainRidge = 10;

  // ============================================================================
  // GROWTH & DECAY THRESHOLDS
  // ============================================================================

  /// Days required to reach Level 1 (starting level)
  static const int growthLevel1MinStreak = 0;

  /// Days required to reach Level 2
  static const int growthLevel2MinStreak = 15;

  /// Days required to reach Level 3 (Post-MVP)
  static const int growthLevel3MinStreak = 30;

  /// Days missed before decay warning state
  static const int decayWarningDays = 1;

  /// Days missed before cloudy decay state
  static const int decayCloudyMinDays = 2;
  static const int decayCloudyMaxDays = 3;

  /// Days missed before stormy decay state
  static const int decayStormyDays = 4;

  /// Completions required to recover from warning state
  static const int recoveryFromWarning = 1;

  /// Completions required to recover from cloudy state
  static const int recoveryFromCloudy = 2;

  /// Completions required to recover from stormy state
  static const int recoveryFromStormy = 3;

  // ============================================================================
  // ISLAND ZONES & XP REQUIREMENTS
  // ============================================================================

  /// XP required to unlock Starter Beach
  static const int xpStarterBeach = 0;

  /// XP required to unlock Forest Grove
  static const int xpForestGrove = 101;

  /// XP required to unlock Mountain Ridge (Post-MVP)
  static const int xpMountainRidge = 301;

  // ============================================================================
  // PREMIUM SUBSCRIPTION (Product Documentation §6.2, §6.3)
  // ============================================================================

  /// Monthly subscription price (USD)
  static const double premiumPriceMonthly = 4.99;

  /// Annual subscription price (USD)
  static const double premiumPriceAnnual = 39.99;

  /// Lifetime subscription launch price (USD)
  static const double premiumPriceLifetimeLaunch = 49.99;

  /// Lifetime subscription regular price (USD)
  static const double premiumPriceLifetimeRegular = 89.99;

  /// Streak shields granted per month for premium users
  static const int premiumStreakShieldsPerMonth = 3;

  /// Maximum vacation days per year for premium users
  static const int premiumVacationDaysPerYear = 30;

  /// Streak recovery uses per month for premium users
  static const int premiumStreakRecoveryPerMonth = 1;

  // ============================================================================
  // ADVERTISING (Product Documentation §6.1)
  // ============================================================================

  /// Maximum rewarded ads per day
  static const int maxRewardedAdsPerDay = 5;

  /// Cooldown between ads in seconds
  static const int adCooldownSeconds = 60;

  /// Target eCPM for ad revenue planning (USD)
  static const double targetEcpm = 12.0;

  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================

  /// Maximum notifications per day (to avoid spam)
  static const int maxNotificationsPerDay = 3;

  /// Do not disturb start hour (24-hour format)
  static const int notificationDndStartHour = 22; // 10 PM

  /// Do not disturb end hour (24-hour format)
  static const int notificationDndEndHour = 8; // 8 AM

  /// Hours before midnight to send streak warning
  static const int streakWarningHoursBeforeMidnight = 2;

  /// Days inactive before re-engagement notification
  static const int reEngagementDaysInactive = 3;

  // ============================================================================
  // WEATHER SYSTEM
  // ============================================================================

  /// Completion rate threshold for rainbow weather (100%)
  static const double weatherRainbowThreshold = 1.0;

  /// Completion rate threshold for sunny weather (75-99%)
  static const double weatherSunnyThreshold = 0.75;

  /// Completion rate threshold for partly cloudy weather (50-74%)
  static const double weatherPartlyCloudyThreshold = 0.50;

  /// Completion rate threshold for cloudy weather (25-49%)
  static const double weatherCloudyThreshold = 0.25;

  /// Below this threshold triggers stormy weather (<25%)
  static const double weatherStormyThreshold = 0.25;

  // ============================================================================
  // SYNC & OFFLINE
  // ============================================================================

  /// Maximum time before forcing a sync (milliseconds)
  static const int syncMaxIntervalMs = 300000; // 5 minutes

  /// Retry delay for failed sync attempts (milliseconds)
  static const int syncRetryDelayMs = 5000; // 5 seconds

  /// Maximum sync retry attempts
  static const int syncMaxRetries = 3;

  /// Days to keep local completion history
  static const int localHistoryDays = 90;

  // ============================================================================
  // ANIMATION & UI (From Design System)
  // ============================================================================

  /// Default animation duration for transitions (milliseconds)
  static const int animationDurationDefault = 300;

  /// Quick animation duration (milliseconds)
  static const int animationDurationQuick = 150;

  /// Slow animation duration (milliseconds)
  static const int animationDurationSlow = 500;

  /// Celebration animation duration (milliseconds)
  static const int animationDurationCelebration = 2000;

  /// Island sprite animation frames per second
  static const int spriteFps = 12;

  /// Particle effects max count
  static const int particleMaxCount = 200;

  /// Particle effects per habit completion
  static const int particlesPerCompletion = 50;

  // ============================================================================
  // ONBOARDING & FIRST RUN
  // ============================================================================

  /// Number of onboarding screens
  static const int onboardingScreenCount = 5;

  /// Suggested habits to show during onboarding
  static const List<String> defaultHabitSuggestions = [
    'Drink 8 glasses of water',
    'Exercise for 30 minutes',
    'Read for 20 minutes',
    'Meditate for 10 minutes',
    'Journal for 15 minutes',
    'Learn something new',
  ];

  // ============================================================================
  // STORAGE & CACHE
  // ============================================================================

  /// Maximum file size for user-uploaded habit icons (bytes)
  static const int maxIconFileSizeBytes = 1048576; // 1 MB

  /// Maximum cached habit completions in memory
  static const int maxCachedCompletions = 1000;

  /// Days before clearing old analytics events
  static const int analyticsRetentionDays = 30;

  // ============================================================================
  // VALIDATION REGEX PATTERNS
  // ============================================================================

  /// Regex for valid habit names (alphanumeric + common punctuation)
  static const String habitNamePattern = r'^[a-zA-Z0-9\s\-_,.!?]+$';

  /// Regex for email validation
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // ============================================================================
  // STREAK CALCULATION
  // ============================================================================

  /// Maximum days to look back when reconstructing streak
  static const int streakReconstructionMaxDays = 365;

  /// Grace period for late-night completions (minutes after midnight)
  static const int streakGracePeriodMinutes = 180; // 3 hours

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Network timeout duration (seconds)
  static const int networkTimeoutSeconds = 30;

  /// Maximum error messages to store
  static const int maxErrorLogSize = 100;

  /// Days to keep error logs
  static const int errorLogRetentionDays = 7;

  // ============================================================================
  // ANALYTICS & METRICS
  // ============================================================================

  /// Target D1 retention rate (Day 1)
  static const double targetD1Retention = 0.50; // 50%

  /// Target D7 retention rate (Day 7)
  static const double targetD7Retention = 0.25; // 25%

  /// Target D30 retention rate (Day 30)
  static const double targetD30Retention = 0.15; // 15%

  /// Target premium conversion rate
  static const double targetPremiumConversion = 0.02; // 2%

  /// Target habit creation rate (% of users who create a habit)
  static const double targetHabitCreationRate = 0.80; // 80%

  // ============================================================================
  // FEATURE FLAGS (MVP vs Post-MVP)
  // ============================================================================

  /// Enable Level 3 growth (Post-MVP)
  static const bool featureLevel3Enabled = false;

  /// Enable Mountain Ridge zone (Post-MVP)
  static const bool featureMountainRidgeEnabled = false;

  /// Enable multiple islands (Post-MVP)
  static const bool featureMultipleIslandsEnabled = false;

  /// Enable dark mode (Post-MVP)
  static const bool featureDarkModeEnabled = false;

  /// Enable social features (Never - per docs)
  static const bool featureSocialEnabled = false;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get XP required for a specific level (placeholder for future leveling system)
  static int xpRequiredForLevel(int level) {
    // Simple exponential curve: 100 * level^2
    return 100 * level * level;
  }

  /// Check if a user is within free tier habit limit
  static bool isWithinFreeLimit(int currentHabits) {
    return currentHabits < maxHabitsFree;
  }

  /// Check if a streak qualifies for milestone bonus
  static int? getStreakMilestoneXp(int streakDays) {
    if (streakDays == 7) return xpBonus7DayStreak;
    if (streakDays == 30) return xpBonus30DayStreak;
    return null;
  }

  /// Get max habits for a specific zone
  static int getMaxHabitsForZone(String zoneName) {
    switch (zoneName) {
      case 'starter_beach':
        return maxHabitsStarterBeach;
      case 'forest_grove':
        return maxHabitsForestGrove;
      case 'mountain_ridge':
        return maxHabitsMountainRidge;
      default:
        return maxHabitsStarterBeach;
    }
  }

  /// Check if time is within do-not-disturb hours
  static bool isInDndWindow(DateTime time) {
    final hour = time.hour;
    return hour >= notificationDndStartHour || hour < notificationDndEndHour;
  }

  /// Calculate streak warning time (2 hours before midnight)
  static DateTime getStreakWarningTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, 22, 0); // 10 PM
  }
}
