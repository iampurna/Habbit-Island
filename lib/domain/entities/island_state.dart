import 'package:equatable/equatable.dart';

/// Island State Entity
/// Domain representation of user's island progress and state

enum IslandTheme { tropical, forest, mountain, desert, arctic }

enum Weather { sunny, cloudy, rainy, stormy, snowy }

class IslandState extends Equatable {
  final String id;
  final String userId;
  final String name;
  final IslandTheme theme;
  final Weather currentWeather;
  final int prosperityLevel;
  final int totalHabitats;
  final int activeHabitats;
  final List<String> unlockedZones;
  final List<String> achievements;
  final Map<String, int> resourceCounts;
  final DateTime lastVisitedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IslandState({
    required this.id,
    required this.userId,
    required this.name,
    required this.theme,
    required this.currentWeather,
    required this.prosperityLevel,
    required this.totalHabitats,
    required this.activeHabitats,
    required this.unlockedZones,
    required this.achievements,
    required this.resourceCounts,
    required this.lastVisitedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    theme,
    currentWeather,
    prosperityLevel,
    totalHabitats,
    activeHabitats,
    unlockedZones,
    achievements,
    resourceCounts,
    lastVisitedAt,
    createdAt,
    updatedAt,
  ];

  // ============================================================================
  // BUSINESS LOGIC
  // ============================================================================

  /// Check if zone is unlocked
  bool isZoneUnlocked(String zoneId) {
    return unlockedZones.contains(zoneId);
  }

  /// Check if achievement is earned
  bool hasAchievement(String achievementId) {
    return achievements.contains(achievementId);
  }

  /// Get resource count
  int getResourceCount(String resourceType) {
    return resourceCounts[resourceType] ?? 0;
  }

  /// Check if has enough resources
  bool hasResources(String resourceType, int amount) {
    return getResourceCount(resourceType) >= amount;
  }

  /// Calculate island health (0.0 - 1.0)
  double get islandHealth {
    // Based on active habitats vs total capacity
    if (totalHabitats == 0) return 1.0;
    return activeHabitats / totalHabitats;
  }

  /// Get prosperity tier (0-5)
  int get prosperityTier {
    return (prosperityLevel / 20).floor().clamp(0, 5);
  }

  /// Calculate progress to next prosperity level
  double get prosperityProgress {
    final currentTierMin = prosperityTier * 20;
    final nextTierMin = (prosperityTier + 1) * 20;
    final progress = prosperityLevel - currentTierMin;
    final range = nextTierMin - currentTierMin;
    return range > 0 ? progress / range : 0.0;
  }

  /// Check if island is thriving (high health, many active habitats)
  bool get isThriving {
    return islandHealth > 0.7 && activeHabitats >= 5;
  }

  /// Check if island needs attention (low health, few active habitats)
  bool get needsAttention {
    return islandHealth < 0.3 || activeHabitats < 2;
  }

  /// Get days since last visit
  int get daysSinceLastVisit {
    return DateTime.now().difference(lastVisitedAt).inDays;
  }

  /// Check if visited today
  bool get visitedToday {
    final now = DateTime.now();
    final lastVisit = lastVisitedAt;
    return now.year == lastVisit.year &&
        now.month == lastVisit.month &&
        now.day == lastVisit.day;
  }

  /// Get unlock progress (percentage of zones unlocked)
  double getUnlockProgress({required int totalZones}) {
    return totalZones > 0 ? unlockedZones.length / totalZones : 0.0;
  }

  /// Get achievement progress
  double getAchievementProgress({required int totalAchievements}) {
    return totalAchievements > 0
        ? achievements.length / totalAchievements
        : 0.0;
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate island state
  bool isValid() {
    // Name must not be empty
    if (name.trim().isEmpty) return false;

    // Counts must be non-negative
    if (prosperityLevel < 0 || totalHabitats < 0 || activeHabitats < 0) {
      return false;
    }

    // Active cannot exceed total
    if (activeHabitats > totalHabitats) return false;

    // Must have at least starter zone
    if (unlockedZones.isEmpty) return false;

    return true;
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  IslandState copyWith({
    String? id,
    String? userId,
    String? name,
    IslandTheme? theme,
    Weather? currentWeather,
    int? prosperityLevel,
    int? totalHabitats,
    int? activeHabitats,
    List<String>? unlockedZones,
    List<String>? achievements,
    Map<String, int>? resourceCounts,
    DateTime? lastVisitedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IslandState(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      theme: theme ?? this.theme,
      currentWeather: currentWeather ?? this.currentWeather,
      prosperityLevel: prosperityLevel ?? this.prosperityLevel,
      totalHabitats: totalHabitats ?? this.totalHabitats,
      activeHabitats: activeHabitats ?? this.activeHabitats,
      unlockedZones: unlockedZones ?? this.unlockedZones,
      achievements: achievements ?? this.achievements,
      resourceCounts: resourceCounts ?? this.resourceCounts,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
