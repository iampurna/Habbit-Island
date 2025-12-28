import 'package:equatable/equatable.dart';
import '../../../domain/entities/habit.dart';

/// Habit States
abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {
  final String? message;

  const HabitLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class HabitsLoaded extends HabitState {
  final List<Habit> habits;
  final HabitCategory? activeFilter;

  const HabitsLoaded({
    required this.habits,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [habits, activeFilter];

  HabitsLoaded copyWith({
    List<Habit>? habits,
    HabitCategory? activeFilter,
  }) {
    return HabitsLoaded(
      habits: habits ?? this.habits,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class Habit

Completed extends HabitState {
  final Habit habit;
  final int xpEarned;
  final bool hadBonus;
  final int newStreak;

  const HabitCompleted({
    required this.habit,
    required this.xpEarned,
    required this.hadBonus,
    required this.newStreak,
  });

  @override
  List<Object> get props => [habit, xpEarned, hadBonus, newStreak];
}

class HabitCreated extends HabitState {
  final Habit habit;

  const HabitCreated(this.habit);

  @override
  List<Object> get props => [habit];
}

class HabitUpdated extends HabitState {
  final Habit habit;

  const HabitUpdated(this.habit);

  @override
  List<Object> get props => [habit];
}

class HabitDeleted extends HabitState {
  final String habitId;

  const HabitDeleted(this.habitId);

  @override
  List<Object> get props => [habitId];
}

class StreakShieldUsed extends HabitState {
  final Habit habit;
  final int shieldsRemaining;

  const StreakShieldUsed({
    required this.habit,
    required this.shieldsRemaining,
  });

  @override
  List<Object> get props => [habit, shieldsRemaining];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object> get props => [message];
}