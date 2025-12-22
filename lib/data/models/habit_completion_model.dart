import 'package:equatable/equatable.dart';

/// Habit Completion Model (Data Layer)
/// Reference: Technical Addendum v1.0 §3.3 (Streak Reconstruction)
///
/// Represents a single completion of a habit on a specific date.
/// Used for streak calculation and history tracking.
/// Never synced directly - always reconstructed from completions.

class HabitCompletionModel extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final DateTime
  logicalDate; // The date this completion counts for (considers grace period)
  final int xpEarned;
  final bool wasBonusDay; // If all daily habits were completed
  final bool wasMilestone; // If this was a 7-day or 30-day milestone
  final String? notes;
  final DateTime createdAt;
  final DateTime? syncedAt;

  const HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.logicalDate,
    required this.xpEarned,
    this.wasBonusDay = false,
    this.wasMilestone = false,
    this.notes,
    required this.createdAt,
    this.syncedAt,
  });

  @override
  List<Object?> get props => [
    id,
    habitId,
    userId,
    completedAt,
    logicalDate,
    xpEarned,
    wasBonusDay,
    wasMilestone,
    notes,
    createdAt,
    syncedAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      logicalDate: DateTime.parse(json['logical_date'] as String),
      xpEarned: json['xp_earned'] as int,
      wasBonusDay: json['was_bonus_day'] as bool? ?? false,
      wasMilestone: json['was_milestone'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'logical_date': logicalDate.toIso8601String(),
      'xp_earned': xpEarned,
      'was_bonus_day': wasBonusDay,
      'was_milestone': wasMilestone,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  HabitCompletionModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    DateTime? logicalDate,
    int? xpEarned,
    bool? wasBonusDay,
    bool? wasMilestone,
    String? notes,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return HabitCompletionModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      logicalDate: logicalDate ?? this.logicalDate,
      xpEarned: xpEarned ?? this.xpEarned,
      wasBonusDay: wasBonusDay ?? this.wasBonusDay,
      wasMilestone: wasMilestone ?? this.wasMilestone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if this completion is for today
  bool get isToday {
    final now = DateTime.now();
    return logicalDate.year == now.year &&
        logicalDate.month == now.month &&
        logicalDate.day == now.day;
  }

  /// Check if this completion is for yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return logicalDate.year == yesterday.year &&
        logicalDate.month == yesterday.month &&
        logicalDate.day == yesterday.day;
  }

  /// Check if completion is within grace period (3 hours after midnight)
  /// Reference: Technical Addendum §3.3
  bool get wasWithinGracePeriod {
    final dayStart = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    final gracePeriodEnd = dayStart.add(const Duration(hours: 3));
    return completedAt.isAfter(dayStart) &&
        completedAt.isBefore(gracePeriodEnd);
  }

  /// Check if needs sync
  bool get needsSync => syncedAt == null;

  /// Check if synced
  bool get isSynced => syncedAt != null;
}
