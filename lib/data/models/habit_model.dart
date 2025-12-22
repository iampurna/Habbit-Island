import 'package:equatable/equatable.dart';

/// Habit Model (Data Layer)
/// Represents a habit with all properties for persistence and API communication.
/// This is the data layer model - convert to domain entity in repositories.

class HabitModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<int>?
  specificDays; // For custom frequency (weekdays: 1-7, Monday=1)
  final DateTime? reminderTime;
  final String zoneId;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final int currentXp;
  final GrowthLevel growthLevel;
  final DecayState decayState;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastCompletedAt;
  final DateTime? lastSyncedAt;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    required this.category,
    required this.frequency,
    this.specificDays,
    this.reminderTime,
    required this.zoneId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.currentXp = 0,
    this.growthLevel = GrowthLevel.level1,
    this.decayState = DecayState.healthy,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.lastCompletedAt,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    icon,
    category,
    frequency,
    specificDays,
    reminderTime,
    zoneId,
    currentStreak,
    longestStreak,
    totalCompletions,
    currentXp,
    growthLevel,
    decayState,
    isActive,
    createdAt,
    updatedAt,
    lastCompletedAt,
    lastSyncedAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      category: HabitCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HabitCategory.other,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      specificDays: json['specific_days'] != null
          ? List<int>.from(json['specific_days'] as List)
          : null,
      reminderTime: json['reminder_time'] != null
          ? DateTime.parse(json['reminder_time'] as String)
          : null,
      zoneId: json['zone_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalCompletions: json['total_completions'] as int? ?? 0,
      currentXp: json['current_xp'] as int? ?? 0,
      growthLevel: GrowthLevel.values.firstWhere(
        (e) => e.name == json['growth_level'],
        orElse: () => GrowthLevel.level1,
      ),
      decayState: DecayState.values.firstWhere(
        (e) => e.name == json['decay_state'],
        orElse: () => DecayState.healthy,
      ),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'] as String)
          : null,
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'frequency': frequency.name,
      'specific_days': specificDays,
      'reminder_time': reminderTime?.toIso8601String(),
      'zone_id': zoneId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_completions': totalCompletions,
      'current_xp': currentXp,
      'growth_level': growthLevel.name,
      'decay_state': decayState.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_completed_at': lastCompletedAt?.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? specificDays,
    DateTime? reminderTime,
    String? zoneId,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    int? currentXp,
    GrowthLevel? growthLevel,
    DecayState? decayState,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastCompletedAt,
    DateTime? lastSyncedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      reminderTime: reminderTime ?? this.reminderTime,
      zoneId: zoneId ?? this.zoneId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      currentXp: currentXp ?? this.currentXp,
      growthLevel: growthLevel ?? this.growthLevel,
      decayState: decayState ?? this.decayState,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if habit should be shown today based on frequency
  bool shouldShowToday(DateTime date) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.custom:
        if (specificDays == null || specificDays!.isEmpty) return false;
        return specificDays!.contains(date.weekday);
      case HabitFrequency.weekly:
        // Weekly habits show on the same day each week
        return specificDays != null && specificDays!.contains(date.weekday);
    }
  }

  /// Check if completed today
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
        lastCompletedAt!.month == now.month &&
        lastCompletedAt!.day == now.day;
  }

  /// Check if streak is active (completed today or yesterday)
  bool get isStreakActive {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastCompleted = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );

    return lastCompleted.isAtSameMomentAs(today) ||
        lastCompleted.isAtSameMomentAs(yesterday);
  }

  /// Get days since last completion
  int get daysSinceLastCompletion {
    if (lastCompletedAt == null) return 999;
    final now = DateTime.now();
    return now.difference(lastCompletedAt!).inDays;
  }
}

// ============================================================================
// ENUMS (Product Documentation §3.1, §4)
// ============================================================================

/// Habit category (Product Documentation §3.1)
enum HabitCategory {
  water, // 💧 - Well → Fountain → Waterfall
  exercise, // 🏃 - Path → Fitness Corner → Mountain Trail
  reading, // 📚 - Books → Reading Nook → Library
  meditation, // 🧘 - Flower → Lotus Pond → Zen Garden
  other, // Generic category
}

/// Habit frequency
enum HabitFrequency {
  daily, // Every day
  weekly, // Specific days each week
  custom, // Custom days (1-7 times per week)
}

/// Growth level (Product Documentation §4.1)
/// Level 1: 0-14 days, 64px, no particles
/// Level 2: 15-29 days, 96px, particles
/// Level 3: 30+ days, 128px, particles (Post-MVP)
enum GrowthLevel {
  level1, // Seedling (0-14 days)
  level2, // Thriving (15-29 days)
  level3, // Flourishing (30+ days, Post-MVP)
}

/// Decay state (Product Documentation §4.2)
enum DecayState {
  healthy, // 0 missed days - normal appearance
  warning, // 1 missed day - 10% darker, 1 completion to recover
  cloudy, // 2-3 missed days - clouds appear, 25% darker, 2 completions to recover
  stormy, // 4+ missed days - storm/lightning, 40% darker, 3 completions to recover
}

// ============================================================================
// HELPER EXTENSIONS
// ============================================================================

extension HabitCategoryExtension on HabitCategory {
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
      case HabitCategory.other:
        return 'Other';
    }
  }

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
      case HabitCategory.other:
        return '⭐';
    }
  }
}

extension GrowthLevelExtension on GrowthLevel {
  String get displayName {
    switch (this) {
      case GrowthLevel.level1:
        return 'Seedling';
      case GrowthLevel.level2:
        return 'Thriving';
      case GrowthLevel.level3:
        return 'Flourishing';
    }
  }

  int get sizePixels {
    switch (this) {
      case GrowthLevel.level1:
        return 64;
      case GrowthLevel.level2:
        return 96;
      case GrowthLevel.level3:
        return 128;
    }
  }

  int get minDays {
    switch (this) {
      case GrowthLevel.level1:
        return 0;
      case GrowthLevel.level2:
        return 15;
      case GrowthLevel.level3:
        return 30;
    }
  }

  int get maxDays {
    switch (this) {
      case GrowthLevel.level1:
        return 14;
      case GrowthLevel.level2:
        return 29;
      case GrowthLevel.level3:
        return 999;
    }
  }
}

extension DecayStateExtension on DecayState {
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

  int get missedDays {
    switch (this) {
      case DecayState.healthy:
        return 0;
      case DecayState.warning:
        return 1;
      case DecayState.cloudy:
        return 2; // 2-3 days
      case DecayState.stormy:
        return 4; // 4+ days
    }
  }

  int get completionsToRecover {
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

  double get darknessPercentage {
    switch (this) {
      case DecayState.healthy:
        return 0.0;
      case DecayState.warning:
        return 0.10;
      case DecayState.cloudy:
        return 0.25;
      case DecayState.stormy:
        return 0.40;
    }
  }
}
