import 'package:equatable/equatable.dart';

/// Habit Streak Model (Data Layer)
/// Reference: Technical Addendum v1.0 §3.3 (Streak Reconstruction)
///
/// Stores calculated streak statistics for a habit.
/// This is a computed/cached model - never the source of truth.
/// Always recalculate from completions on sync.

class HabitStreakModel extends Equatable {
  final String habitId;
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? currentStreakStartDate;
  final DateTime? longestStreakStartDate;
  final DateTime? longestStreakEndDate;
  final DateTime? lastCompletionDate;
  final int totalCompletions;
  final int completionsThisWeek;
  final int completionsThisMonth;
  final int completionsThisYear;
  final List<int>
  milestonesDays; // Days where milestones were hit (7, 30, 60, etc.)
  final bool isActive; // Completed today or yesterday
  final DateTime calculatedAt;

  const HabitStreakModel({
    required this.habitId,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.currentStreakStartDate,
    this.longestStreakStartDate,
    this.longestStreakEndDate,
    this.lastCompletionDate,
    this.totalCompletions = 0,
    this.completionsThisWeek = 0,
    this.completionsThisMonth = 0,
    this.completionsThisYear = 0,
    this.milestonesDays = const [],
    this.isActive = false,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
    habitId,
    userId,
    currentStreak,
    longestStreak,
    currentStreakStartDate,
    longestStreakStartDate,
    longestStreakEndDate,
    lastCompletionDate,
    totalCompletions,
    completionsThisWeek,
    completionsThisMonth,
    completionsThisYear,
    milestonesDays,
    isActive,
    calculatedAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory HabitStreakModel.fromJson(Map<String, dynamic> json) {
    return HabitStreakModel(
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      currentStreakStartDate: json['current_streak_start_date'] != null
          ? DateTime.parse(json['current_streak_start_date'] as String)
          : null,
      longestStreakStartDate: json['longest_streak_start_date'] != null
          ? DateTime.parse(json['longest_streak_start_date'] as String)
          : null,
      longestStreakEndDate: json['longest_streak_end_date'] != null
          ? DateTime.parse(json['longest_streak_end_date'] as String)
          : null,
      lastCompletionDate: json['last_completion_date'] != null
          ? DateTime.parse(json['last_completion_date'] as String)
          : null,
      totalCompletions: json['total_completions'] as int? ?? 0,
      completionsThisWeek: json['completions_this_week'] as int? ?? 0,
      completionsThisMonth: json['completions_this_month'] as int? ?? 0,
      completionsThisYear: json['completions_this_year'] as int? ?? 0,
      milestonesDays: json['milestones_days'] != null
          ? List<int>.from(json['milestones_days'] as List)
          : const [],
      isActive: json['is_active'] as bool? ?? false,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'current_streak_start_date': currentStreakStartDate?.toIso8601String(),
      'longest_streak_start_date': longestStreakStartDate?.toIso8601String(),
      'longest_streak_end_date': longestStreakEndDate?.toIso8601String(),
      'last_completion_date': lastCompletionDate?.toIso8601String(),
      'total_completions': totalCompletions,
      'completions_this_week': completionsThisWeek,
      'completions_this_month': completionsThisMonth,
      'completions_this_year': completionsThisYear,
      'milestones_days': milestonesDays,
      'is_active': isActive,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  HabitStreakModel copyWith({
    String? habitId,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? currentStreakStartDate,
    DateTime? longestStreakStartDate,
    DateTime? longestStreakEndDate,
    DateTime? lastCompletionDate,
    int? totalCompletions,
    int? completionsThisWeek,
    int? completionsThisMonth,
    int? completionsThisYear,
    List<int>? milestonesDays,
    bool? isActive,
    DateTime? calculatedAt,
  }) {
    return HabitStreakModel(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreakStartDate:
          currentStreakStartDate ?? this.currentStreakStartDate,
      longestStreakStartDate:
          longestStreakStartDate ?? this.longestStreakStartDate,
      longestStreakEndDate: longestStreakEndDate ?? this.longestStreakEndDate,
      lastCompletionDate: lastCompletionDate ?? this.lastCompletionDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      completionsThisWeek: completionsThisWeek ?? this.completionsThisWeek,
      completionsThisMonth: completionsThisMonth ?? this.completionsThisMonth,
      completionsThisYear: completionsThisYear ?? this.completionsThisYear,
      milestonesDays: milestonesDays ?? this.milestonesDays,
      isActive: isActive ?? this.isActive,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get next milestone day
  int? get nextMilestone {
    const milestones = [7, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    return null; // Already past 365 days!
  }

  /// Days until next milestone
  int? get daysUntilNextMilestone {
    final next = nextMilestone;
    if (next == null) return null;
    return next - currentStreak;
  }

  /// Check if hit a milestone with this streak
  bool isMilestone(int streak) {
    const milestones = [7, 30, 60, 90, 180, 365];
    return milestones.contains(streak);
  }

  /// Get completion rate this week (0.0 to 1.0)
  double get weeklyCompletionRate {
    // Assuming 7 days per week
    return completionsThisWeek / 7.0;
  }

  /// Get completion rate this month (0.0 to 1.0)
  double get monthlyCompletionRate {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return completionsThisMonth / daysInMonth.toDouble();
  }

  /// Check if streak is broken (no completion yesterday or today)
  bool get isBroken => !isActive && currentStreak == 0;

  /// Check if streak is at risk (no completion today)
  bool get isAtRisk {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompletion = DateTime(
      lastCompletionDate!.year,
      lastCompletionDate!.month,
      lastCompletionDate!.day,
    );
    return lastCompletion.isBefore(today) && isActive;
  }

  /// Days since last completion
  int get daysSinceLastCompletion {
    if (lastCompletionDate == null) return 999;
    final now = DateTime.now();
    return now.difference(lastCompletionDate!).inDays;
  }

  /// Get current streak duration in days
  int get streakDuration {
    if (currentStreakStartDate == null) return 0;
    final now = DateTime.now();
    return now.difference(currentStreakStartDate!).inDays + 1;
  }

  /// Get longest streak duration in days
  int? get longestStreakDuration {
    if (longestStreakStartDate == null || longestStreakEndDate == null) {
      return longestStreak;
    }
    return longestStreakEndDate!.difference(longestStreakStartDate!).inDays + 1;
  }
}
