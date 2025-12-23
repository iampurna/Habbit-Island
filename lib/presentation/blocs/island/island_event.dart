import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habbit_island/presentation/blocs/habit/habit_event.dart';
import 'package:habbit_island/presentation/blocs/habit/habit_state.dart';
import '../../../domain/use_cases/habits/create_habit.dart';
import '../../../domain/use_cases/habits/complete_habit.dart';
import '../../../domain/use_cases/habits/update_habit.dart';
import '../../../domain/use_cases/habits/delete_habit.dart';
import '../../../domain/use_cases/habits/get_habits.dart';
import '../../../domain/use_cases/streaks/use_streak_shield.dart';
import '../../../core/utils/app_logger.dart';

/// Habit BLoC - Manages habit state and operations
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final CreateHabit _createHabit;
  final CompleteHabit _completeHabit;
  final UpdateHabit _updateHabit;
  final DeleteHabit _deleteHabit;
  final GetHabits _getHabits;
  final UseStreakShield _useStreakShield;

  HabitBloc({
    required CreateHabit createHabit,
    required CompleteHabit completeHabit,
    required UpdateHabit updateHabit,
    required DeleteHabit deleteHabit,
    required GetHabits getHabits,
    required UseStreakShield useStreakShield,
  }) : _createHabit = createHabit,
       _completeHabit = completeHabit,
       _updateHabit = updateHabit,
       _deleteHabit = deleteHabit,
       _getHabits = getHabits,
       _useStreakShield = useStreakShield,
       super(HabitInitial()) {
    on<HabitsLoadRequested>(_onHabitsLoadRequested);
    on<HabitsByZoneLoadRequested>(_onHabitsByZoneLoadRequested);
    on<HabitCreateRequested>(_onHabitCreateRequested);
    on<HabitUpdateRequested>(_onHabitUpdateRequested);
    on<HabitDeleteRequested>(_onHabitDeleteRequested);
    on<HabitCompleteRequested>(_onHabitCompleteRequested);
    on<StreakShieldUseRequested>(_onStreakShieldUseRequested);
    on<HabitsFilteredByCategory>(_onHabitsFilteredByCategory);
  }

  Future<void> _onHabitsLoadRequested(
    HabitsLoadRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Loading habits...'));

      final result = await _getHabits.execute(
        userId: event.userId,
        activeOnly: event.activeOnly,
      );

      result.fold(
        (failure) {
          AppLogger.error('HabitBloc: Failed to load habits', failure);
          emit(HabitError(failure.message));
        },
        (habits) {
          AppLogger.debug('HabitBloc: Loaded ${habits.length} habits');
          emit(HabitsLoaded(habits: habits));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Load habits error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onHabitsByZoneLoadRequested(
    HabitsByZoneLoadRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Loading zone habits...'));

      final result = await _getHabits.execute(
        userId: event.userId,
        zoneId: event.zoneId,
      );

      result.fold(
        (failure) => emit(HabitError(failure.message)),
        (habits) => emit(HabitsLoaded(habits: habits)),
      );
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Load zone habits error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onHabitCreateRequested(
    HabitCreateRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Creating habit...'));

      final result = await _createHabit.execute(
        userId: event.userId,
        name: event.name,
        description: event.description,
        category: event.category,
        frequency: event.frequency,
        customFrequencyDays: event.customFrequencyDays,
        zoneId: event.zoneId,
        reminderTime: event.reminderTime,
      );

      result.fold(
        (failure) {
          AppLogger.error('HabitBloc: Create habit failed', failure);
          emit(HabitError(failure.message));
        },
        (habit) {
          AppLogger.info('HabitBloc: Habit created - ${habit.id}');
          emit(HabitCreated(habit));
          // Reload habits
          add(HabitsLoadRequested(userId: event.userId));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Create habit error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onHabitUpdateRequested(
    HabitUpdateRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Updating habit...'));

      final result = await _updateHabit.execute(
        habitId: event.habitId,
        name: event.name,
        description: event.description,
        category: event.category,
        frequency: event.frequency,
        zoneId: event.zoneId,
        reminderTime: event.reminderTime,
        isActive: event.isActive,
      );

      result.fold((failure) => emit(HabitError(failure.message)), (habit) {
        AppLogger.info('HabitBloc: Habit updated - ${habit.id}');
        emit(HabitUpdated(habit));
      });
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Update habit error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onHabitDeleteRequested(
    HabitDeleteRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Deleting habit...'));

      final result = await _deleteHabit.execute(
        habitId: event.habitId,
        hardDelete: event.hardDelete,
      );

      result.fold((failure) => emit(HabitError(failure.message)), (_) {
        AppLogger.info('HabitBloc: Habit deleted - ${event.habitId}');
        emit(HabitDeleted(event.habitId));
      });
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Delete habit error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onHabitCompleteRequested(
    HabitCompleteRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Completing habit...'));

      final result = await _completeHabit.execute(
        userId: event.userId,
        habitId: event.habitId,
        notes: event.notes,
      );

      result.fold(
        (failure) {
          AppLogger.error('HabitBloc: Complete habit failed', failure);
          emit(HabitError(failure.message));
        },
        (completionResult) {
          AppLogger.info(
            'HabitBloc: Habit completed - Earned ${completionResult.xpEarned} XP',
          );
          emit(
            HabitCompleted(
              habit: completionResult.habit,
              xpEarned: completionResult.xpEarned,
              hadBonus: completionResult.hadBonus,
              newStreak: completionResult.newStreak,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Complete habit error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onStreakShieldUseRequested(
    StreakShieldUseRequested event,
    Emitter<HabitState> emit,
  ) async {
    try {
      emit(const HabitLoading(message: 'Using streak shield...'));

      final result = await _useStreakShield.execute(
        userId: event.userId,
        habitId: event.habitId,
      );

      result.fold(
        (failure) {
          AppLogger.error('HabitBloc: Streak shield failed', failure);
          emit(HabitError(failure.message));
        },
        (shieldResult) {
          AppLogger.info('HabitBloc: Streak shield used');
          emit(
            StreakShieldUsed(
              habit: shieldResult.habit,
              shieldsRemaining: shieldResult.shieldsRemaining,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('HabitBloc: Streak shield error', e, stackTrace);
      emit(HabitError(e.toString()));
    }
  }

  void _onHabitsFilteredByCategory(
    HabitsFilteredByCategory event,
    Emitter<HabitState> emit,
  ) {
    if (state is HabitsLoaded) {
      final currentState = state as HabitsLoaded;
      // Apply filter logic
      emit(currentState.copyWith(activeFilter: event.category));
    }
  }
}
