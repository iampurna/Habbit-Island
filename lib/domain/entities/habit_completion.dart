import 'package:equatable/equatable.dart';

/// Habit Completion Entity
/// Domain representation of a single habit completion event

class HabitCompletion extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final String? notes;
  final int xpEarned;
  final bool hadBonus;
  final DateTime createdAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    this.notes,
    required this.xpEarned,
    required this.hadBonus,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    habitId,
    userId,
    completedAt,
    notes,
    xpEarned,
    hadBonus,
    createdAt,
  ];

  // ============================================================================
  // BUSINESS LOGIC
  // ============================================================================

  /// Check if completion is from today
  bool get isToday {
    final now = DateTime.now();
    return now.year == completedAt.year &&
        now.month == completedAt.month &&
        now.day == completedAt.day;
  }

  /// Check if completion is from yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year == completedAt.year &&
        yesterday.month == completedAt.month &&
        yesterday.day == completedAt.day;
  }

  /// Check if completion is within the last N days
  bool isWithinDays(int days) {
    final now = DateTime.now();
    final difference = now.difference(completedAt).inDays;
    return difference <= days;
  }

  /// Get days ago (0 = today, 1 = yesterday, etc.)
  int get daysAgo {
    final now = DateTime.now();
    final difference = now.difference(completedAt);
    return difference.inDays;
  }

  /// Check if completion is valid (not in future, reasonable XP)
  bool isValid() {
    // Cannot be completed in the future
    if (completedAt.isAfter(DateTime.now())) return false;

    // XP should be reasonable (base 10, max 700 with bonuses)
    if (xpEarned < 0 || xpEarned > 700) return false;

    // Habit ID and User ID must exist
    if (habitId.isEmpty || userId.isEmpty) return false;

    return true;
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    String? notes,
    int? xpEarned,
    bool? hadBonus,
    DateTime? createdAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      xpEarned: xpEarned ?? this.xpEarned,
      hadBonus: hadBonus ?? this.hadBonus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
