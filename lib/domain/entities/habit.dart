import 'package:equatable/equatable.dart';

/// Habit Entity
/// Core domain model for habits with business logic
class Habit extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final String? customFrequencyDays;
  final String zoneId;
  final String? reminderTime;
  final bool isActive;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final DateTime? lastCompletedAt;
  final GrowthStage growthStage;
  final int growthLevel;
  final double growthProgress;
  final DecayState decayState;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    required this.frequency,
    this.customFrequencyDays,
    required this.zoneId,
    this.reminderTime,
    this.isActive = true,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.lastCompletedAt,
    this.growthStage = GrowthStage.seed,
    this.growthLevel = 1,
    this.growthProgress = 0.0,
    this.decayState = DecayState.healthy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    category,
    frequency,
    customFrequencyDays,
    zoneId,
    reminderTime,
    isActive,
    currentStreak,
    longestStreak,
    totalCompletions,
    lastCompletedAt,
    growthStage,
    growthLevel,
    growthProgress,
    decayState,
    createdAt,
    updatedAt,
  ];

  // ============================================================================
  // BUSINESS LOGIC METHODS
  // ============================================================================

  /// Check if habit was completed today
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;

    final now = DateTime.now();
    final lastCompleted = lastCompletedAt!;

    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }

  /// Check if habit is overdue (based on frequency)
  bool get isOverdue {
    if (lastCompletedAt == null && frequency == HabitFrequency.daily) {
      // Never completed daily habit
      return createdAt.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    if (lastCompletedAt == null) return false;

    final now = DateTime.now();
    final daysSinceCompletion = now.difference(lastCompletedAt!).inDays;

    switch (frequency) {
      case HabitFrequency.daily:
        return daysSinceCompletion >= 1;
      case HabitFrequency.weekly:
        return daysSinceCompletion >= 7;
      case HabitFrequency.custom:
        // Custom frequency implementation
        return false;
    }
  }

  /// Check if habit is at risk of losing streak
  bool get isAtRisk {
    return isOverdue || decayState != DecayState.healthy;
  }

  /// Check if habit can grow to next stage
  bool get canGrow {
    return currentStreak >= _getGrowthRequirement() &&
        growthStage != GrowthStage.forest;
  }

  /// Get days until habit can grow
  int get daysUntilGrowth {
    if (!canGrow) {
      final requirement = _getGrowthRequirement();
      return requirement - currentStreak;
    }
    return 0;
  }

  /// Get next growth stage
  GrowthStage? get nextGrowthStage {
    switch (growthStage) {
      case GrowthStage.seed:
        return GrowthStage.sprout;
      case GrowthStage.sprout:
        return GrowthStage.sapling;
      case GrowthStage.sapling:
        return GrowthStage.tree;
      case GrowthStage.tree:
        return GrowthStage.forest;
      case GrowthStage.forest:
        return null; // Max stage
    }
  }

  /// Get streak requirement for current growth stage
  int _getGrowthRequirement() {
    switch (growthStage) {
      case GrowthStage.seed:
        return 7; // 7 days to sprout
      case GrowthStage.sprout:
        return 14; // 14 days to sapling
      case GrowthStage.sapling:
        return 30; // 30 days to tree
      case GrowthStage.tree:
        return 60; // 60 days to forest
      case GrowthStage.forest:
        return 999; // Max stage
    }
  }

  /// Calculate growth progress percentage
  double calculateGrowthProgress() {
    if (growthStage == GrowthStage.forest) return 1.0;

    final requirement = _getGrowthRequirement();
    return (currentStreak / requirement).clamp(0.0, 1.0);
  }

  /// Get habit category color
  String getCategoryColorHex() {
    switch (category) {
      case HabitCategory.water:
        return '#2196F3';
      case HabitCategory.exercise:
        return '#F44336';
      case HabitCategory.mindfulness:
        return '#9C27B0';
      case HabitCategory.nutrition:
        return '#4CAF50';
      case HabitCategory.sleep:
        return '#3F51B5';
      case HabitCategory.productivity:
        return '#FF9800';
      case HabitCategory.learning:
        return '#009688';
      case HabitCategory.social:
        return '#E91E63';
      case HabitCategory.creative:
        return '#FFC107';
      case HabitCategory.reading:
        return '#795548';
      case HabitCategory.meditation:
        return '#673AB7';
      case HabitCategory.custom:
        return '#607D8B';
    }
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitCategory? category,
    HabitFrequency? frequency,
    String? customFrequencyDays,
    String? zoneId,
    String? reminderTime,
    bool? isActive,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    DateTime? lastCompletedAt,
    GrowthStage? growthStage,
    int? growthLevel,
    double? growthProgress,
    DecayState? decayState,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customFrequencyDays: customFrequencyDays ?? this.customFrequencyDays,
      zoneId: zoneId ?? this.zoneId,
      reminderTime: reminderTime ?? this.reminderTime,
      isActive: isActive ?? this.isActive,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      growthStage: growthStage ?? this.growthStage,
      growthLevel: growthLevel ?? this.growthLevel,
      growthProgress: growthProgress ?? this.growthProgress,
      decayState: decayState ?? this.decayState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ============================================================================
// ENUMS
// ============================================================================

enum HabitCategory {
  water,
  exercise,
  mindfulness,
  nutrition,
  sleep,
  productivity,
  learning,
  social,
  creative,
  reading,
  meditation,
  custom,
}

enum HabitFrequency { daily, weekly, custom }

enum GrowthStage { seed, sprout, sapling, tree, forest }

enum DecayState { healthy, warning, cloudy, stormy }
