import 'package:equatable/equatable.dart';

/// Island Events
/// User actions that trigger island state changes

abstract class IslandEvent extends Equatable {
  const IslandEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// ISLAND LOAD EVENTS
// ============================================================================

/// Load island for user
class IslandLoadRequested extends IslandEvent {
  final String userId;

  const IslandLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

// ============================================================================
// ISLAND UPDATE EVENTS
// ============================================================================

/// Update island properties
class IslandUpdateRequested extends IslandEvent {
  final String islandId;
  final String? name;

  const IslandUpdateRequested({required this.islandId, this.name});

  @override
  List<Object?> get props => [islandId, name];
}

// ============================================================================
// ZONE EVENTS
// ============================================================================

/// Unlock new zone
class ZoneUnlockRequested extends IslandEvent {
  final String userId;
  final String zoneId;

  const ZoneUnlockRequested({required this.userId, required this.zoneId});

  @override
  List<Object> get props => [userId, zoneId];
}

// ============================================================================
// ACHIEVEMENT EVENTS
// ============================================================================

/// Unlock achievement
class AchievementUnlockRequested extends IslandEvent {
  final String userId;
  final String achievementId;

  const AchievementUnlockRequested({
    required this.userId,
    required this.achievementId,
  });

  @override
  List<Object> get props => [userId, achievementId];
}

// ============================================================================
// WEATHER EVENTS
// ============================================================================

/// Update island weather based on habit completion percentage
class WeatherUpdateRequested extends IslandEvent {
  final String userId;
  final double completionPercentage;

  const WeatherUpdateRequested({
    required this.userId,
    required this.completionPercentage,
  });

  @override
  List<Object> get props => [userId, completionPercentage];
}
