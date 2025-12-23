import 'package:equatable/equatable.dart';

/// Habit Streak Entity
/// Domain representation of a habit's streak information

enum StreakStatus { active, atRisk, broken, protected }

class HabitStreak extends Equatable {
  final String habitId;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;
  final DateTime? streakStartedAt;
  final StreakStatus status;
  final bool shieldActive;
  final DateTime? shieldUsedAt;
  final int consecutiveDays;
  final DateTime updatedAt;

  const HabitStreak({
    required this.habitId,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedAt,
    this.streakStartedAt,
    required this.status,
    required this.shieldActive,
    this.shieldUsedAt,
    required this.consecutiveDays,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    habitId,
    userId,
    currentStreak,
    longestStreak,
    lastCompletedAt,
    streakStartedAt,
    status,
    shieldActive,
    shieldUsedAt,
    consecutiveDays,
    updatedAt,
  ];

  // ============================================================================
  // BUSINESS LOGIC
  // ============================================================================

  /// Check if streak is active (completed today or yesterday)
  bool get isActive {
    if (lastCompletedAt == null) return false;

    final now = DateTime.now();
    final lastCompleted = lastCompletedAt!;
    final daysSince = now.difference(lastCompleted).inDays;

    return daysSince <= 1;
  }

  /// Check if streak is at risk (not completed today, but completed yesterday)
  bool get isAtRisk {
    if (lastCompletedAt == null) return false;

    final now = DateTime.now();
    final lastCompleted = lastCompletedAt!;
    final daysSince = now.difference(lastCompleted).inDays;

    return daysSince == 1;
  }

  /// Check if streak is broken (more than 1 day since last completion)
  bool get isBroken {
    if (lastCompletedAt == null) return currentStreak == 0;

    final now = DateTime.now();
    final lastCompleted = lastCompletedAt!;
    final daysSince = now.difference(lastCompleted).inDays;

    return daysSince > 1 && !shieldActive;
  }

  /// Check if streak can use shield
  bool get canUseShield {
    // Shield not already active
    if (shieldActive) return false;

    // Must have a streak to protect
    if (currentStreak == 0) return false;

    // Must be at risk or recently broken
    return isAtRisk || isBroken;
  }

  /// Calculate streak percentage to next milestone (7, 30, 90, 180, 365)
  double get progressToNextMilestone {
    final milestones = [7, 30, 90, 180, 365];

    // Find next milestone
    int nextMilestone = milestones.firstWhere(
      (m) => currentStreak < m,
      orElse: () => 365,
    );

    // If past all milestones, show progress toward next 100
    if (currentStreak >= 365) {
      nextMilestone = ((currentStreak ~/ 100) + 1) * 100;
    }

    // Calculate previous milestone
    final previousMilestone = milestones.lastWhere(
      (m) => currentStreak >= m,
      orElse: () => 0,
    );

    // Calculate progress
    final range = nextMilestone - previousMilestone;
    final progress = currentStreak - previousMilestone;

    return range > 0 ? progress / range : 0.0;
  }

  /// Get next milestone
  int get nextMilestone {
    const milestones = [7, 30, 90, 180, 365];

    return milestones.firstWhere(
      (m) => currentStreak < m,
      orElse: () => ((currentStreak ~/ 100) + 1) * 100,
    );
  }

  /// Check if achieved milestone
  bool hasMilestone(int milestone) {
    return currentStreak >= milestone;
  }

  /// Get streak duration in days
  int get streakDuration {
    if (streakStartedAt == null) return currentStreak;

    final now = DateTime.now();
    return now.difference(streakStartedAt!).inDays + 1;
  }

  /// Check if longest streak is current streak
  bool get isPersonalBest {
    return currentStreak == longestStreak && longestStreak > 0;
  }

  /// Calculate days until shield expires (24 hours from use)
  int? get shieldHoursRemaining {
    if (!shieldActive || shieldUsedAt == null) return null;

    final expiresAt = shieldUsedAt!.add(const Duration(hours: 24));
    final now = DateTime.now();

    if (now.isAfter(expiresAt)) return 0;

    return expiresAt.difference(now).inHours;
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate streak data
  bool isValid() {
    // Current streak cannot be negative
    if (currentStreak < 0) return false;

    // Longest streak must be >= current streak
    if (longestStreak < currentStreak) return false;

    // If shield active, must have shield used date
    if (shieldActive && shieldUsedAt == null) return false;

    // If streak exists, must have last completed date
    if (currentStreak > 0 && lastCompletedAt == null) return false;

    return true;
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  HabitStreak copyWith({
    String? habitId,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedAt,
    DateTime? streakStartedAt,
    StreakStatus? status,
    bool? shieldActive,
    DateTime? shieldUsedAt,
    int? consecutiveDays,
    DateTime? updatedAt,
  }) {
    return HabitStreak(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      streakStartedAt: streakStartedAt ?? this.streakStartedAt,
      status: status ?? this.status,
      shieldActive: shieldActive ?? this.shieldActive,
      shieldUsedAt: shieldUsedAt ?? this.shieldUsedAt,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
