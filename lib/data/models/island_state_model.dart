import 'package:equatable/equatable.dart';

/// Island State Model (Data Layer)
/// Reference: Product Documentation v1.0 §4 (Island Visualization)
///
/// Represents the current state of a user's island including zones,
/// weather, and visual elements.

class IslandStateModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final IslandTheme theme;
  final List<IslandZoneState> zones;
  final WeatherCondition currentWeather;
  final double overallCompletionRate; // 0.0 to 1.0
  final int totalXp;
  final DateTime lastUpdatedAt;
  final DateTime createdAt;

  const IslandStateModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.theme,
    required this.zones,
    required this.currentWeather,
    required this.overallCompletionRate,
    this.totalXp = 0,
    required this.lastUpdatedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    theme,
    zones,
    currentWeather,
    overallCompletionRate,
    totalXp,
    lastUpdatedAt,
    createdAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory IslandStateModel.fromJson(Map<String, dynamic> json) {
    return IslandStateModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      theme: IslandTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => IslandTheme.tropical,
      ),
      zones: (json['zones'] as List)
          .map((e) => IslandZoneState.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentWeather: WeatherCondition.values.firstWhere(
        (e) => e.name == json['current_weather'],
        orElse: () => WeatherCondition.sunny,
      ),
      overallCompletionRate: (json['overall_completion_rate'] as num)
          .toDouble(),
      totalXp: json['total_xp'] as int? ?? 0,
      lastUpdatedAt: DateTime.parse(json['last_updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'theme': theme.name,
      'zones': zones.map((e) => e.toJson()).toList(),
      'current_weather': currentWeather.name,
      'overall_completion_rate': overallCompletionRate,
      'total_xp': totalXp,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  IslandStateModel copyWith({
    String? id,
    String? userId,
    String? name,
    IslandTheme? theme,
    List<IslandZoneState>? zones,
    WeatherCondition? currentWeather,
    double? overallCompletionRate,
    int? totalXp,
    DateTime? lastUpdatedAt,
    DateTime? createdAt,
  }) {
    return IslandStateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      zones: zones ?? this.zones,
      currentWeather: currentWeather ?? this.currentWeather,
      overallCompletionRate:
          overallCompletionRate ?? this.overallCompletionRate,
      totalXp: totalXp ?? this.totalXp,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get unlocked zones
  List<IslandZoneState> get unlockedZones =>
      zones.where((z) => z.isUnlocked).toList();

  /// Get zone by ID
  IslandZoneState? getZone(String zoneId) {
    try {
      return zones.firstWhere((z) => z.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  /// Check if zone is unlocked
  bool isZoneUnlocked(String zoneId) {
    final zone = getZone(zoneId);
    return zone?.isUnlocked ?? false;
  }

  /// Get total habits across all zones
  int get totalHabits => zones.fold(0, (sum, zone) => sum + zone.habitCount);

  /// Get total active habits
  int get totalActiveHabits =>
      zones.fold(0, (sum, zone) => sum + zone.activeHabitCount);
}

// ============================================================================
// ISLAND ZONE STATE
// ============================================================================

/// Represents the state of a single zone on the island
class IslandZoneState extends Equatable {
  final String id;
  final String name;
  final IslandZoneType type;
  final bool isUnlocked;
  final int xpRequired;
  final int habitCount;
  final int activeHabitCount;
  final int maxHabits;
  final double completionRate; // 0.0 to 1.0
  final WeatherCondition localWeather;

  const IslandZoneState({
    required this.id,
    required this.name,
    required this.type,
    required this.isUnlocked,
    required this.xpRequired,
    required this.habitCount,
    required this.activeHabitCount,
    required this.maxHabits,
    required this.completionRate,
    required this.localWeather,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    isUnlocked,
    xpRequired,
    habitCount,
    activeHabitCount,
    maxHabits,
    completionRate,
    localWeather,
  ];

  factory IslandZoneState.fromJson(Map<String, dynamic> json) {
    return IslandZoneState(
      id: json['id'] as String,
      name: json['name'] as String,
      type: IslandZoneType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IslandZoneType.starterBeach,
      ),
      isUnlocked: json['is_unlocked'] as bool,
      xpRequired: json['xp_required'] as int,
      habitCount: json['habit_count'] as int,
      activeHabitCount: json['active_habit_count'] as int,
      maxHabits: json['max_habits'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      localWeather: WeatherCondition.values.firstWhere(
        (e) => e.name == json['local_weather'],
        orElse: () => WeatherCondition.sunny,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'is_unlocked': isUnlocked,
      'xp_required': xpRequired,
      'habit_count': habitCount,
      'active_habit_count': activeHabitCount,
      'max_habits': maxHabits,
      'completion_rate': completionRate,
      'local_weather': localWeather.name,
    };
  }

  IslandZoneState copyWith({
    String? id,
    String? name,
    IslandZoneType? type,
    bool? isUnlocked,
    int? xpRequired,
    int? habitCount,
    int? activeHabitCount,
    int? maxHabits,
    double? completionRate,
    WeatherCondition? localWeather,
  }) {
    return IslandZoneState(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      xpRequired: xpRequired ?? this.xpRequired,
      habitCount: habitCount ?? this.habitCount,
      activeHabitCount: activeHabitCount ?? this.activeHabitCount,
      maxHabits: maxHabits ?? this.maxHabits,
      completionRate: completionRate ?? this.completionRate,
      localWeather: localWeather ?? this.localWeather,
    );
  }

  /// Check if zone is full
  bool get isFull => habitCount >= maxHabits;

  /// Get available slots
  int get availableSlots => maxHabits - habitCount;
}

// ============================================================================
// ENUMS
// ============================================================================

/// Island theme (future feature, currently only tropical)
enum IslandTheme {
  tropical, // Default tropical island theme
  // Future: desert, arctic, fantasy, etc.
}

/// Island zone type (Product Documentation §4.3)
enum IslandZoneType {
  starterBeach, // 0 XP, 4 habits max (MVP)
  forestGrove, // 101 XP, 7 habits max (MVP)
  mountainRidge, // 301 XP, 10 habits max (Post-MVP)
}

/// Weather condition (Product Documentation §4.4)
enum WeatherCondition {
  rainbow, // 100% completion - Rainbow arc, sparkles
  sunny, // 75-99% completion - Sun rays, clear sky
  partlyCloudy, // 50-74% completion - Light clouds
  cloudy, // 25-49% completion - Dark clouds
  stormy, // <25% completion - Rain, lightning
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension IslandZoneTypeExtension on IslandZoneType {
  String get displayName {
    switch (this) {
      case IslandZoneType.starterBeach:
        return 'Starter Beach';
      case IslandZoneType.forestGrove:
        return 'Forest Grove';
      case IslandZoneType.mountainRidge:
        return 'Mountain Ridge';
    }
  }

  int get xpRequired {
    switch (this) {
      case IslandZoneType.starterBeach:
        return 0;
      case IslandZoneType.forestGrove:
        return 101;
      case IslandZoneType.mountainRidge:
        return 301;
    }
  }

  int get maxHabits {
    switch (this) {
      case IslandZoneType.starterBeach:
        return 4;
      case IslandZoneType.forestGrove:
        return 7;
      case IslandZoneType.mountainRidge:
        return 10;
    }
  }

  String get colorHex {
    switch (this) {
      case IslandZoneType.starterBeach:
        return '#F5DEB3'; // Sandy beige
      case IslandZoneType.forestGrove:
        return '#228B22'; // Forest green
      case IslandZoneType.mountainRidge:
        return '#708090'; // Slate grey
    }
  }

  bool get isPostMvp => this == IslandZoneType.mountainRidge;
}

extension WeatherConditionExtension on WeatherCondition {
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

  double get minCompletionRate {
    switch (this) {
      case WeatherCondition.rainbow:
        return 1.0;
      case WeatherCondition.sunny:
        return 0.75;
      case WeatherCondition.partlyCloudy:
        return 0.50;
      case WeatherCondition.cloudy:
        return 0.25;
      case WeatherCondition.stormy:
        return 0.0;
    }
  }

  String get description {
    switch (this) {
      case WeatherCondition.rainbow:
        return 'Perfect! All habits completed today!';
      case WeatherCondition.sunny:
        return 'Great progress! Keep it up!';
      case WeatherCondition.partlyCloudy:
        return 'Making progress, but room to improve.';
      case WeatherCondition.cloudy:
        return 'Habits need attention today.';
      case WeatherCondition.stormy:
        return 'Time to get back on track!';
    }
  }
}
