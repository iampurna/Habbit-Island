// =============================================================================
// HABIT ISLAND - CONSOLIDATED ENUMS
// =============================================================================
// This file consolidates all enums to prevent duplicate definitions.
// All other files should import from this single source.
// =============================================================================

/// Habit Category - Maps to specific island visual progression
/// Per spec: Only 4 MVP categories with unique sprite progressions
enum HabitCategory {
  /// Water habits: Well → Fountain → Waterfall
  water,

  /// Exercise habits: Path → Fitness Corner → Mountain Trail
  exercise,

  /// Reading habits: Books → Reading Nook → Library
  reading,

  /// Meditation habits: Flower → Lotus Pond → Zen Garden
  meditation;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case HabitCategory.water:
        return 'Water';
      case HabitCategory.exercise:
        return 'Exercise';
      case HabitCategory.reading:
        return 'Reading';
      case HabitCategory.meditation:
        return 'Meditation';
    }
  }

  /// Get icon name for this category
  String get iconName {
    switch (this) {
      case HabitCategory.water:
        return 'water_drop';
      case HabitCategory.exercise:
        return 'fitness_center';
      case HabitCategory.reading:
        return 'menu_book';
      case HabitCategory.meditation:
        return 'self_improvement';
    }
  }

  /// Get emoji representation
  String get emoji {
    switch (this) {
      case HabitCategory.water:
        return '💧';
      case HabitCategory.exercise:
        return '🏃';
      case HabitCategory.reading:
        return '📚';
      case HabitCategory.meditation:
        return '🧘';
    }
  }

  /// Get growth stages for this category
  List<String> get growthStages {
    switch (this) {
      case HabitCategory.water:
        return ['Well', 'Fountain', 'Waterfall'];
      case HabitCategory.exercise:
        return ['Path', 'Fitness Corner', 'Mountain Trail'];
      case HabitCategory.reading:
        return ['Books', 'Reading Nook', 'Library'];
      case HabitCategory.meditation:
        return ['Flower', 'Lotus Pond', 'Zen Garden'];
    }
  }

  /// Convert from string (for JSON deserialization)
  static HabitCategory fromString(String value) {
    return HabitCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => HabitCategory.water,
    );
  }
}

/// Habit Frequency - How often a habit should be completed
enum HabitFrequency {
  /// Every day
  daily,

  /// Specific days of the week (e.g., Mon/Wed/Fri)
  specificDays,

  /// X times per week
  timesPerWeek;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.specificDays:
        return 'Specific Days';
      case HabitFrequency.timesPerWeek:
        return 'Times Per Week';
    }
  }

  /// Convert from string (for JSON deserialization)
  static HabitFrequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return HabitFrequency.daily;
      case 'specific_days':
      case 'specificdays':
        return HabitFrequency.specificDays;
      case 'times_per_week':
      case 'timesperweek':
        return HabitFrequency.timesPerWeek;
      default:
        return HabitFrequency.daily;
    }
  }

  /// Convert to string for JSON serialization
  String toJsonString() {
    switch (this) {
      case HabitFrequency.daily:
        return 'daily';
      case HabitFrequency.specificDays:
        return 'specific_days';
      case HabitFrequency.timesPerWeek:
        return 'times_per_week';
    }
  }
}

/// Premium Tier - Subscription levels
enum PremiumTier {
  /// Free tier with ads and limited features
  free,

  /// Monthly subscription
  monthly,

  /// Annual subscription (33% savings)
  annual,

  /// One-time lifetime purchase
  lifetime;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.monthly:
        return 'Monthly';
      case PremiumTier.annual:
        return 'Annual';
      case PremiumTier.lifetime:
        return 'Lifetime';
    }
  }

  /// Get price string
  String get priceString {
    switch (this) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.monthly:
        return '\$4.99/month';
      case PremiumTier.annual:
        return '\$39.99/year';
      case PremiumTier.lifetime:
        return '\$49.99';
    }
  }

  /// Check if this tier is premium (paid)
  bool get isPremium => this != PremiumTier.free;

  /// Convert from string (for JSON deserialization)
  static PremiumTier fromString(String? value) {
    if (value == null) return PremiumTier.free;
    return PremiumTier.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => PremiumTier.free,
    );
  }
}

/// Weather Condition - Island weather based on habit completion rate
enum WeatherCondition {
  /// 100% completion - Rainbow arc, extra sparkles
  rainbow,

  /// 75-99% completion - Bright, sun rays, happy clouds
  sunny,

  /// 50-74% completion - Light clouds drifting
  partlyCloudy,

  /// 25-49% completion - Darker clouds, muted colors
  cloudy,

  /// <25% completion - Rain particles, lightning, dark overlay
  stormy;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case WeatherCondition.rainbow:
        return 'Rainbow';
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.stormy:
        return 'Stormy';
    }
  }

  /// Get emoji for weather
  String get emoji {
    switch (this) {
      case WeatherCondition.rainbow:
        return '🌈';
      case WeatherCondition.sunny:
        return '☀️';
      case WeatherCondition.partlyCloudy:
        return '⛅';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.stormy:
        return '⛈️';
    }
  }

  /// Calculate weather from completion percentage
  static WeatherCondition fromCompletionRate(double rate) {
    if (rate >= 1.0) return WeatherCondition.rainbow;
    if (rate >= 0.75) return WeatherCondition.sunny;
    if (rate >= 0.50) return WeatherCondition.partlyCloudy;
    if (rate >= 0.25) return WeatherCondition.cloudy;
    return WeatherCondition.stormy;
  }

  /// Convert from string (for JSON deserialization)
  static WeatherCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'rainbow':
        return WeatherCondition.rainbow;
      case 'sunny':
        return WeatherCondition.sunny;
      case 'partly_cloudy':
      case 'partlycloudy':
        return WeatherCondition.partlyCloudy;
      case 'cloudy':
        return WeatherCondition.cloudy;
      case 'stormy':
        return WeatherCondition.stormy;
      default:
        return WeatherCondition.sunny;
    }
  }

  /// Convert to string for JSON serialization
  String toJsonString() {
    switch (this) {
      case WeatherCondition.rainbow:
        return 'rainbow';
      case WeatherCondition.sunny:
        return 'sunny';
      case WeatherCondition.partlyCloudy:
        return 'partly_cloudy';
      case WeatherCondition.cloudy:
        return 'cloudy';
      case WeatherCondition.stormy:
        return 'stormy';
    }
  }
}

/// Decay State - Visual decay state for habits when missed
enum DecayState {
  /// No missed days - Normal sprite
  healthy,

  /// 1 day missed - 10% darker, subtle pulse
  warning,

  /// 2-3 days missed - Clouds over object, 25% darker
  cloudy,

  /// 4+ days missed - Storm, lightning, wilt
  stormy;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case DecayState.healthy:
        return 'Healthy';
      case DecayState.warning:
        return 'Warning';
      case DecayState.cloudy:
        return 'Cloudy';
      case DecayState.stormy:
        return 'Stormy';
    }
  }

  /// Get recovery completions required
  int get recoveryCompletionsRequired {
    switch (this) {
      case DecayState.healthy:
        return 0;
      case DecayState.warning:
        return 1;
      case DecayState.cloudy:
        return 2;
      case DecayState.stormy:
        return 3;
    }
  }

  /// Calculate decay state from days missed
  static DecayState fromDaysMissed(int daysMissed) {
    if (daysMissed <= 0) return DecayState.healthy;
    if (daysMissed == 1) return DecayState.warning;
    if (daysMissed <= 3) return DecayState.cloudy;
    return DecayState.stormy;
  }

  /// Convert from string (for JSON deserialization)
  static DecayState fromString(String value) {
    return DecayState.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => DecayState.healthy,
    );
  }
}

/// Growth Stage - Visual growth level for habit sprites
enum GrowthStage {
  /// Level 1: 0-14 day streak - 64x64px, muted colors
  seedling,

  /// Level 2: 15-29 day streak - 96x96px, vibrant colors
  growing,

  /// Level 3: 30+ day streak - 128x128px, glowing effects (Post-MVP)
  flourishing;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case GrowthStage.seedling:
        return 'Seedling';
      case GrowthStage.growing:
        return 'Growing';
      case GrowthStage.flourishing:
        return 'Flourishing';
    }
  }

  /// Get level number (1-3)
  int get level {
    switch (this) {
      case GrowthStage.seedling:
        return 1;
      case GrowthStage.growing:
        return 2;
      case GrowthStage.flourishing:
        return 3;
    }
  }

  /// Get sprite size in pixels
  int get spriteSize {
    switch (this) {
      case GrowthStage.seedling:
        return 64;
      case GrowthStage.growing:
        return 96;
      case GrowthStage.flourishing:
        return 128;
    }
  }

  /// Calculate growth stage from streak days
  static GrowthStage fromStreakDays(int days) {
    if (days >= 30) return GrowthStage.flourishing;
    if (days >= 15) return GrowthStage.growing;
    return GrowthStage.seedling;
  }

  /// Convert from string (for JSON deserialization)
  static GrowthStage fromString(String value) {
    return GrowthStage.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => GrowthStage.seedling,
    );
  }
}

/// Completion Source - How a habit completion was recorded
enum CompletionSource {
  /// User manually marked complete
  manual,

  /// Restored via undo
  undoRestore,

  /// Protected by streak shield (premium)
  streakShield;

  /// Convert from string (for JSON deserialization)
  static CompletionSource fromString(String value) {
    switch (value.toLowerCase()) {
      case 'manual':
        return CompletionSource.manual;
      case 'undo_restore':
      case 'undorestore':
        return CompletionSource.undoRestore;
      case 'streak_shield':
      case 'streakshield':
        return CompletionSource.streakShield;
      default:
        return CompletionSource.manual;
    }
  }

  /// Convert to string for JSON serialization
  String toJsonString() {
    switch (this) {
      case CompletionSource.manual:
        return 'manual';
      case CompletionSource.undoRestore:
        return 'undo_restore';
      case CompletionSource.streakShield:
        return 'streak_shield';
    }
  }
}

/// XP Event Type - Types of XP earning events
enum XpEventType {
  /// Completing any habit (+10 XP)
  habitComplete,

  /// Completing all daily habits (+50 XP bonus)
  allDailyComplete,

  /// Achieving 7-day streak (+100 XP)
  streak7,

  /// Achieving 30-day streak (+500 XP)
  streak30,

  /// Daily login bonus (+5 XP)
  dailyLogin,

  /// Watching rewarded ad (+50 XP)
  rewardedAd;

  /// Get XP amount for this event type
  int get xpAmount {
    switch (this) {
      case XpEventType.habitComplete:
        return 10;
      case XpEventType.allDailyComplete:
        return 50;
      case XpEventType.streak7:
        return 100;
      case XpEventType.streak30:
        return 500;
      case XpEventType.dailyLogin:
        return 5;
      case XpEventType.rewardedAd:
        return 50;
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case XpEventType.habitComplete:
        return 'Habit Complete';
      case XpEventType.allDailyComplete:
        return 'All Daily Complete';
      case XpEventType.streak7:
        return '7-Day Streak';
      case XpEventType.streak30:
        return '30-Day Streak';
      case XpEventType.dailyLogin:
        return 'Daily Login';
      case XpEventType.rewardedAd:
        return 'Rewarded Ad';
    }
  }

  /// Convert from string (for JSON deserialization)
  static XpEventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'habit_complete':
      case 'habitcomplete':
        return XpEventType.habitComplete;
      case 'all_daily':
      case 'all_daily_complete':
      case 'alldailycomplete':
        return XpEventType.allDailyComplete;
      case 'streak_7':
      case 'streak7':
        return XpEventType.streak7;
      case 'streak_30':
      case 'streak30':
        return XpEventType.streak30;
      case 'daily_login':
      case 'dailylogin':
        return XpEventType.dailyLogin;
      case 'rewarded_ad':
      case 'rewardedad':
        return XpEventType.rewardedAd;
      default:
        return XpEventType.habitComplete;
    }
  }

  /// Convert to string for JSON serialization
  String toJsonString() {
    switch (this) {
      case XpEventType.habitComplete:
        return 'habit_complete';
      case XpEventType.allDailyComplete:
        return 'all_daily_complete';
      case XpEventType.streak7:
        return 'streak_7';
      case XpEventType.streak30:
        return 'streak_30';
      case XpEventType.dailyLogin:
        return 'daily_login';
      case XpEventType.rewardedAd:
        return 'rewarded_ad';
    }
  }
}

/// Island Zone - Unlockable island areas
enum IslandZone {
  /// Starting area: 0-100 XP, 4 habit slots
  starterBeach,

  /// Second zone: 101-300 XP, 7 habit slots
  forestGrove,

  /// Third zone: 301-600 XP, 10 habit slots (Post-MVP)
  mountainRidge;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case IslandZone.starterBeach:
        return 'Starter Beach';
      case IslandZone.forestGrove:
        return 'Forest Grove';
      case IslandZone.mountainRidge:
        return 'Mountain Ridge';
    }
  }

  /// Get zone ID for database
  String get zoneId {
    switch (this) {
      case IslandZone.starterBeach:
        return 'starter-beach';
      case IslandZone.forestGrove:
        return 'forest-grove';
      case IslandZone.mountainRidge:
        return 'mountain-ridge';
    }
  }

  /// Get XP required to unlock
  int get xpRequired {
    switch (this) {
      case IslandZone.starterBeach:
        return 0;
      case IslandZone.forestGrove:
        return 101;
      case IslandZone.mountainRidge:
        return 301;
    }
  }

  /// Get maximum habit slots
  int get habitSlots {
    switch (this) {
      case IslandZone.starterBeach:
        return 4;
      case IslandZone.forestGrove:
        return 7;
      case IslandZone.mountainRidge:
        return 10;
    }
  }

  /// Check if zone is available in MVP
  bool get isMvp {
    switch (this) {
      case IslandZone.starterBeach:
      case IslandZone.forestGrove:
        return true;
      case IslandZone.mountainRidge:
        return false;
    }
  }

  /// Get zone from XP amount
  static IslandZone fromXp(int xp) {
    if (xp >= 301) return IslandZone.mountainRidge;
    if (xp >= 101) return IslandZone.forestGrove;
    return IslandZone.starterBeach;
  }

  /// Convert from string (for JSON deserialization)
  static IslandZone fromString(String value) {
    switch (value.toLowerCase().replaceAll('-', '').replaceAll('_', '')) {
      case 'starterbeach':
        return IslandZone.starterBeach;
      case 'forestgrove':
        return IslandZone.forestGrove;
      case 'mountainridge':
        return IslandZone.mountainRidge;
      default:
        return IslandZone.starterBeach;
    }
  }
}
