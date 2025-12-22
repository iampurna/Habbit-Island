import 'package:flutter/material.dart';
import 'package:habbit_island/core/theme/app_colors.dart';
import 'package:habbit_island/core/theme/app_dimensions.dart';
import 'app_constants.dart';

/// Habit Island Game Mechanics Constants
/// This file contains all island-specific constants including:
/// - Growth levels and visual characteristics
/// - Island zones and their properties
/// - Weather system states
/// - Decay mechanics and recovery rules

// ============================================================================
// ENUMS
// ============================================================================

/// Growth levels for habit objects (Product Documentation §4.1)
enum GrowthLevel {
  level1, // 0-14 day streak
  level2, // 15-29 day streak
  level3, // 30+ day streak (Post-MVP)
}

/// Decay states for missed habits (Product Documentation §4.2)
enum DecayState {
  healthy, // No days missed
  warning, // 1 day missed
  cloudy, // 2-3 days missed
  stormy, // 4+ days missed
}

/// Weather conditions reflecting overall habit completion (Product Documentation §4.4)
enum WeatherCondition {
  rainbow, // 100% completion
  sunny, // 75-99% completion
  partlyCloudy, // 50-74% completion
  cloudy, // 25-49% completion
  stormy, // <25% completion
}

/// Island zones (Product Documentation §4.3)
enum IslandZone {
  starterBeach, // 0-100 XP, 4 slots
  forestGrove, // 101-300 XP, 7 slots
  mountainRidge, // 301-600 XP, 10 slots (Post-MVP)
}

/// Habit categories (Product Documentation §3.1)
enum HabitCategory {
  water, // Well → Fountain → Waterfall
  exercise, // Path → Fitness Corner → Mountain Trail
  reading, // Books → Reading Nook → Library
  meditation, // Flower → Lotus Pond → Zen Garden
}

// ============================================================================
// GROWTH LEVEL CONFIGURATION
// ============================================================================

class GrowthLevelConfig {
  final GrowthLevel level;
  final int minStreak;
  final int? maxStreak;
  final double spriteSize;
  final String visualDescription;
  final bool hasParticleEffects;
  final bool isMvp;

  const GrowthLevelConfig({
    required this.level,
    required this.minStreak,
    this.maxStreak,
    required this.spriteSize,
    required this.visualDescription,
    required this.hasParticleEffects,
    required this.isMvp,
  });
}

class IslandConstants {
  IslandConstants._(); // Private constructor

  // ============================================================================
  // GROWTH LEVELS
  // ============================================================================

  static const List<GrowthLevelConfig> growthLevels = [
    GrowthLevelConfig(
      level: GrowthLevel.level1,
      minStreak: 0,
      maxStreak: 14,
      spriteSize: AppDimensions.spriteLevel1Size, // 64px
      visualDescription:
          'Small version, muted colors, minimal detail, basic idle animation',
      hasParticleEffects: false,
      isMvp: true,
    ),
    GrowthLevelConfig(
      level: GrowthLevel.level2,
      minStreak: 15,
      maxStreak: 29,
      spriteSize: AppDimensions.spriteLevel2Size, // 96px
      visualDescription:
          'Full size, vibrant colors, detailed artwork, smooth animations, particle effects',
      hasParticleEffects: true,
      isMvp: true,
    ),
    GrowthLevelConfig(
      level: GrowthLevel.level3,
      minStreak: 30,
      maxStreak: null, // No upper limit
      spriteSize: AppDimensions.spriteLevel3Size, // 128px
      visualDescription:
          'Epic size, glowing effects, maximum detail, premium animations',
      hasParticleEffects: true,
      isMvp: false, // Post-MVP
    ),
  ];

  /// Get growth level configuration based on streak days
  static GrowthLevelConfig getGrowthLevelForStreak(int streakDays) {
    // Filter to MVP levels only
    final availableLevels = growthLevels
        .where((config) => config.isMvp)
        .toList();

    // Find the appropriate level
    for (final config in availableLevels.reversed) {
      if (streakDays >= config.minStreak) {
        if (config.maxStreak == null || streakDays <= config.maxStreak!) {
          return config;
        }
      }
    }

    // Default to level 1
    return availableLevels.first;
  }

  // ============================================================================
  // DECAY STATES
  // ============================================================================

  static const Map<DecayState, DecayStateConfig> decayStates = {
    DecayState.healthy: DecayStateConfig(
      state: DecayState.healthy,
      daysMissed: 0,
      visualEffect: 'Normal sprite',
      colorModifier: 1.0,
      hasCloudEffect: false,
      hasStormEffect: false,
      recoveryRequired: 0,
    ),
    DecayState.warning: DecayStateConfig(
      state: DecayState.warning,
      daysMissed: 1,
      visualEffect: '10% darker, subtle pulse',
      colorModifier: 0.9,
      hasCloudEffect: false,
      hasStormEffect: false,
      recoveryRequired: AppConstants.recoveryFromWarning, // 1 completion
    ),
    DecayState.cloudy: DecayStateConfig(
      state: DecayState.cloudy,
      daysMissed: 2, // 2-3 days
      visualEffect: 'Clouds over object, 25% darker',
      colorModifier: 0.75,
      hasCloudEffect: true,
      hasStormEffect: false,
      recoveryRequired: AppConstants.recoveryFromCloudy, // 2 completions
    ),
    DecayState.stormy: DecayStateConfig(
      state: DecayState.stormy,
      daysMissed: 4, // 4+ days
      visualEffect: 'Storm, lightning, wilt',
      colorModifier: 0.6,
      hasCloudEffect: false,
      hasStormEffect: true,
      recoveryRequired: AppConstants.recoveryFromStormy, // 3 completions
    ),
  };

  /// Get decay state based on consecutive days missed
  static DecayState getDecayState(int daysMissed) {
    if (daysMissed == 0) return DecayState.healthy;
    if (daysMissed == 1) return DecayState.warning;
    if (daysMissed >= 2 && daysMissed <= 3) return DecayState.cloudy;
    return DecayState.stormy; // 4+ days
  }

  // ============================================================================
  // ISLAND ZONES
  // ============================================================================

  static const List<IslandZoneConfig> zones = [
    IslandZoneConfig(
      zone: IslandZone.starterBeach,
      name: 'Starter Beach',
      xpRequired: 0,
      maxHabits: 4,
      backgroundColor: AppColors.sandBeige,
      isMvp: true,
      description: 'Your first home on the island',
    ),
    IslandZoneConfig(
      zone: IslandZone.forestGrove,
      name: 'Forest Grove',
      xpRequired: 101,
      maxHabits: 7,
      backgroundColor: AppColors.islandGreen,
      isMvp: true,
      description: 'A lush forest area with more space',
    ),
    IslandZoneConfig(
      zone: IslandZone.mountainRidge,
      name: 'Mountain Ridge',
      xpRequired: 301,
      maxHabits: 10,
      backgroundColor: Color(0xFF90A4AE),
      isMvp: false, // Post-MVP
      description: 'The highest point of your island',
    ),
  ];

  /// Get available zones based on user XP
  static List<IslandZoneConfig> getAvailableZones(int userXp) {
    return zones.where((zone) => userXp >= zone.xpRequired).toList();
  }

  /// Get next zone to unlock
  static IslandZoneConfig? getNextZone(int userXp) {
    final lockedZones = zones.where((zone) => userXp < zone.xpRequired);
    return lockedZones.isEmpty ? null : lockedZones.first;
  }

  // ============================================================================
  // WEATHER SYSTEM
  // ============================================================================

  static const Map<WeatherCondition, WeatherConfig> weatherConditions = {
    WeatherCondition.rainbow: WeatherConfig(
      condition: WeatherCondition.rainbow,
      minCompletionRate: 1.0,
      maxCompletionRate: 1.0,
      visualEffect: 'Rainbow arc, extra sparkles',
      skyColor: AppColors.weatherRainbow,
      particleColor: AppColors.accent,
      hasRainEffect: false,
      hasLightningEffect: false,
      hasSunEffect: true,
      hasRainbowEffect: true,
    ),
    WeatherCondition.sunny: WeatherConfig(
      condition: WeatherCondition.sunny,
      minCompletionRate: 0.75,
      maxCompletionRate: 0.99,
      visualEffect: 'Bright, sun rays, happy clouds',
      skyColor: AppColors.weatherSunny,
      particleColor: AppColors.accent,
      hasRainEffect: false,
      hasLightningEffect: false,
      hasSunEffect: true,
      hasRainbowEffect: false,
    ),
    WeatherCondition.partlyCloudy: WeatherConfig(
      condition: WeatherCondition.partlyCloudy,
      minCompletionRate: 0.50,
      maxCompletionRate: 0.74,
      visualEffect: 'Light clouds drifting',
      skyColor: AppColors.weatherCloudy,
      particleColor: Colors.white70,
      hasRainEffect: false,
      hasLightningEffect: false,
      hasSunEffect: false,
      hasRainbowEffect: false,
    ),
    WeatherCondition.cloudy: WeatherConfig(
      condition: WeatherCondition.cloudy,
      minCompletionRate: 0.25,
      maxCompletionRate: 0.49,
      visualEffect: 'Darker clouds, muted colors',
      skyColor: AppColors.weatherCloudy,
      particleColor: Colors.grey,
      hasRainEffect: false,
      hasLightningEffect: false,
      hasSunEffect: false,
      hasRainbowEffect: false,
    ),
    WeatherCondition.stormy: WeatherConfig(
      condition: WeatherCondition.stormy,
      minCompletionRate: 0.0,
      maxCompletionRate: 0.24,
      visualEffect: 'Rain particles, lightning, dark overlay',
      skyColor: AppColors.weatherStormy,
      particleColor: Colors.white,
      hasRainEffect: true,
      hasLightningEffect: true,
      hasSunEffect: false,
      hasRainbowEffect: false,
    ),
  };

  /// Get weather condition based on completion rate
  static WeatherCondition getWeatherForCompletionRate(double completionRate) {
    if (completionRate >= 1.0) return WeatherCondition.rainbow;
    if (completionRate >= 0.75) return WeatherCondition.sunny;
    if (completionRate >= 0.50) return WeatherCondition.partlyCloudy;
    if (completionRate >= 0.25) return WeatherCondition.cloudy;
    return WeatherCondition.stormy;
  }

  // ============================================================================
  // HABIT CATEGORIES
  // ============================================================================

  static const Map<HabitCategory, HabitCategoryConfig> habitCategories = {
    HabitCategory.water: HabitCategoryConfig(
      category: HabitCategory.water,
      name: 'Water',
      icon: '💧',
      color: AppColors.waterCategory,
      progression: ['Well', 'Fountain', 'Waterfall'],
      description: 'Hydration and water-related habits',
    ),
    HabitCategory.exercise: HabitCategoryConfig(
      category: HabitCategory.exercise,
      name: 'Exercise',
      icon: '🏃',
      color: AppColors.exerciseCategory,
      progression: ['Path', 'Fitness Corner', 'Mountain Trail'],
      description: 'Physical activity and movement habits',
    ),
    HabitCategory.reading: HabitCategoryConfig(
      category: HabitCategory.reading,
      name: 'Reading',
      icon: '📚',
      color: AppColors.readingCategory,
      progression: ['Books', 'Reading Nook', 'Library'],
      description: 'Reading and learning habits',
    ),
    HabitCategory.meditation: HabitCategoryConfig(
      category: HabitCategory.meditation,
      name: 'Meditation',
      icon: '🧘',
      color: AppColors.meditationCategory,
      progression: ['Flower', 'Lotus Pond', 'Zen Garden'],
      description: 'Mindfulness and meditation habits',
    ),
  };

  /// Get habit category by enum
  static HabitCategoryConfig getCategoryConfig(HabitCategory category) {
    return habitCategories[category]!;
  }

  /// Get habit visual progression name
  static String getProgressionName(HabitCategory category, GrowthLevel level) {
    final config = habitCategories[category]!;
    final index = level.index;
    if (index < config.progression.length) {
      return config.progression[index];
    }
    return config.progression.last;
  }
}

// ============================================================================
// CONFIGURATION CLASSES
// ============================================================================

class DecayStateConfig {
  final DecayState state;
  final int daysMissed;
  final String visualEffect;
  final double colorModifier;
  final bool hasCloudEffect;
  final bool hasStormEffect;
  final int recoveryRequired;

  const DecayStateConfig({
    required this.state,
    required this.daysMissed,
    required this.visualEffect,
    required this.colorModifier,
    required this.hasCloudEffect,
    required this.hasStormEffect,
    required this.recoveryRequired,
  });
}

class IslandZoneConfig {
  final IslandZone zone;
  final String name;
  final int xpRequired;
  final int maxHabits;
  final Color backgroundColor;
  final bool isMvp;
  final String description;

  const IslandZoneConfig({
    required this.zone,
    required this.name,
    required this.xpRequired,
    required this.maxHabits,
    required this.backgroundColor,
    required this.isMvp,
    required this.description,
  });
}

class WeatherConfig {
  final WeatherCondition condition;
  final double minCompletionRate;
  final double maxCompletionRate;
  final String visualEffect;
  final Color skyColor;
  final Color particleColor;
  final bool hasRainEffect;
  final bool hasLightningEffect;
  final bool hasSunEffect;
  final bool hasRainbowEffect;

  const WeatherConfig({
    required this.condition,
    required this.minCompletionRate,
    required this.maxCompletionRate,
    required this.visualEffect,
    required this.skyColor,
    required this.particleColor,
    required this.hasRainEffect,
    required this.hasLightningEffect,
    required this.hasSunEffect,
    required this.hasRainbowEffect,
  });
}

class HabitCategoryConfig {
  final HabitCategory category;
  final String name;
  final String icon;
  final Color color;
  final List<String> progression;
  final String description;

  const HabitCategoryConfig({
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    required this.progression,
    required this.description,
  });
}
