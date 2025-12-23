import 'package:equatable/equatable.dart';

/// Habit Entity
/// Domain layer representation of a habit
/// Contains business logic and validation rules

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
  custom,
}

enum HabitFrequency { daily, weekly, custom }

enum GrowthStage { seed, sprout, sapling, tree, forest }

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
  final int decayCounter;
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
    required this.isActive,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    this.lastCompletedAt,
    required this.growthStage,
    required this.growthLevel,
    required this.decayCounter,
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
    decayCounter,
    createdAt,
    updatedAt,
  ];

  // ============================================================================
  // BUSINESS LOGIC
  // ============================================================================

  /// Check if habit is completed today
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;

    final now = DateTime.now();
    final lastCompleted = lastCompletedAt!;

    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }

  /// Check if habit is overdue (should have been completed but wasn't)
  bool get isOverdue {
    if (lastCompletedAt == null)
      return createdAt.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      );

    final daysSinceLastCompletion = DateTime.now()
        .difference(lastCompletedAt!)
        .inDays;

    switch (frequency) {
      case HabitFrequency.daily:
        return daysSinceLastCompletion > 1;
      case HabitFrequency.weekly:
        return daysSinceLastCompletion > 7;
      case HabitFrequency.custom:
        // For custom frequency, consider overdue if more than the longest interval
        return daysSinceLastCompletion > 7;
    }
  }

  /// Check if habit is at risk of breaking streak (missed yesterday)
  bool get isAtRisk {
    if (lastCompletedAt == null) return false;

    final daysSinceLastCompletion = DateTime.now()
        .difference(lastCompletedAt!)
        .inDays;
    return daysSinceLastCompletion == 1;
  }

  /// Calculate growth progress (0.0 - 1.0)
  double get growthProgress {
    // Each stage requires 10 completions
    const completionsPerStage = 10;
    final currentStageCompletions = growthLevel % completionsPerStage;
    return currentStageCompletions / completionsPerStage;
  }

  /// Get next growth stage
  GrowthStage get nextGrowthStage {
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
        return GrowthStage.forest; // Max stage
    }
  }

  /// Check if ready to grow to next stage
  bool get canGrow {
    if (growthStage == GrowthStage.forest) return false;
    return growthLevel >= _getRequiredLevelForNextStage();
  }

  int _getRequiredLevelForNextStage() {
    switch (growthStage) {
      case GrowthStage.seed:
        return 10; // 10 completions to sprout
      case GrowthStage.sprout:
        return 20; // 20 total to sapling
      case GrowthStage.sapling:
        return 40; // 40 total to tree
      case GrowthStage.tree:
        return 80; // 80 total to forest
      case GrowthStage.forest:
        return 999; // Already at max
    }
  }

  /// Check if habit needs decay evaluation
  bool get needsDecayCheck {
    if (lastCompletedAt == null) return false;
    final daysSinceCompletion = DateTime.now()
        .difference(lastCompletedAt!)
        .inDays;
    return daysSinceCompletion >= 2; // Check decay after 2+ days
  }

  /// Calculate decay severity (0-3)
  int get decaySeverity {
    if (lastCompletedAt == null) return 0;

    final daysSinceCompletion = DateTime.now()
        .difference(lastCompletedAt!)
        .inDays;

    if (daysSinceCompletion < 2) return 0; // No decay
    if (daysSinceCompletion < 4) return 1; // Minor decay
    if (daysSinceCompletion < 7) return 2; // Moderate decay
    return 3; // Severe decay
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate habit name
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.length <= 50;
  }

  /// Validate habit data
  bool isValid() {
    return isValidName(name) &&
        zoneId.isNotEmpty &&
        currentStreak >= 0 &&
        longestStreak >= 0 &&
        totalCompletions >= 0 &&
        growthLevel >= 0 &&
        decayCounter >= 0;
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

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
    int? decayCounter,
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
      decayCounter: decayCounter ?? this.decayCounter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
