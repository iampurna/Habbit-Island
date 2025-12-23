import 'package:equatable/equatable.dart';
import '../../../domain/entities/habit.dart';

/// Habit Events
/// User actions that trigger habit state changes

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// HABIT CRUD EVENTS
// ============================================================================

/// Load habits for user
class HabitsLoadRequested extends HabitEvent {
  final String userId;
  final bool activeOnly;

  const HabitsLoadRequested({required this.userId, this.activeOnly = false});

  @override
  List<Object> get props => [userId, activeOnly];
}

/// Load habits for specific zone
class HabitsByZoneLoadRequested extends HabitEvent {
  final String userId;
  final String zoneId;

  const HabitsByZoneLoadRequested({required this.userId, required this.zoneId});

  @override
  List<Object> get props => [userId, zoneId];
}

/// Create new habit
class HabitCreateRequested extends HabitEvent {
  final String userId;
  final String name;
  final String? description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final String? customFrequencyDays;
  final String zoneId;
  final String? reminderTime;

  const HabitCreateRequested({
    required this.userId,
    required this.name,
    this.description,
    required this.category,
    required this.frequency,
    this.customFrequencyDays,
    required this.zoneId,
    this.reminderTime,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    description,
    category,
    frequency,
    customFrequencyDays,
    zoneId,
    reminderTime,
  ];
}

/// Update existing habit
class HabitUpdateRequested extends HabitEvent {
  final String habitId;
  final String? name;
  final String? description;
  final HabitCategory? category;
  final HabitFrequency? frequency;
  final String? zoneId;
  final String? reminderTime;
  final bool? isActive;

  const HabitUpdateRequested({
    required this.habitId,
    this.name,
    this.description,
    this.category,
    this.frequency,
    this.zoneId,
    this.reminderTime,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    habitId,
    name,
    description,
    category,
    frequency,
    zoneId,
    reminderTime,
    isActive,
  ];
}

/// Delete habit
class HabitDeleteRequested extends HabitEvent {
  final String habitId;
  final bool hardDelete;

  const HabitDeleteRequested({required this.habitId, this.hardDelete = false});

  @override
  List<Object> get props => [habitId, hardDelete];
}

// ============================================================================
// HABIT COMPLETION EVENTS
// ============================================================================

/// Complete habit
class HabitCompleteRequested extends HabitEvent {
  final String userId;
  final String habitId;
  final String? notes;

  const HabitCompleteRequested({
    required this.userId,
    required this.habitId,
    this.notes,
  });

  @override
  List<Object?> get props => [userId, habitId, notes];
}

/// Undo habit completion
class HabitCompletionUndoRequested extends HabitEvent {
  final String habitId;
  final String completionId;

  const HabitCompletionUndoRequested({
    required this.habitId,
    required this.completionId,
  });

  @override
  List<Object> get props => [habitId, completionId];
}

// ============================================================================
// STREAK EVENTS
// ============================================================================

/// Calculate streak for habit
class StreakCalculationRequested extends HabitEvent {
  final String habitId;
  final String userId;

  const StreakCalculationRequested({
    required this.habitId,
    required this.userId,
  });

  @override
  List<Object> get props => [habitId, userId];
}

/// Use streak shield
class StreakShieldUseRequested extends HabitEvent {
  final String userId;
  final String habitId;

  const StreakShieldUseRequested({required this.userId, required this.habitId});

  @override
  List<Object> get props => [userId, habitId];
}

/// Evaluate decay
class DecayEvaluationRequested extends HabitEvent {
  final String habitId;

  const DecayEvaluationRequested(this.habitId);

  @override
  List<Object> get props => [habitId];
}

// ============================================================================
// FILTER/SORT EVENTS
// ============================================================================

/// Filter habits by category
class HabitsFilteredByCategory extends HabitEvent {
  final HabitCategory? category;

  const HabitsFilteredByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Sort habits
class HabitsSorted extends HabitEvent {
  final HabitSortType sortType;

  const HabitsSorted(this.sortType);

  @override
  List<Object> get props => [sortType];
}

enum HabitSortType { name, streak, createdDate, lastCompleted }
