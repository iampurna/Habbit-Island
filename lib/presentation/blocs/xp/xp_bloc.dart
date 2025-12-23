import 'package:flutter_bloc/flutter_bloc.dart';
import 'xp_event.dart';
import 'xp_state.dart';
import '../../../domain/use_cases/xp/award_xp.dart';
import '../../../domain/use_cases/xp/calculate_level.dart';
import '../../../core/utils/app_logger.dart';

class XpBloc extends Bloc<XpEvent, XpState> {
  final AwardXp _awardXp;
  final CalculateLevel _calculateLevel;

  XpBloc({required AwardXp awardXp, required CalculateLevel calculateLevel})
    : _awardXp = awardXp,
      _calculateLevel = calculateLevel,
      super(XpInitial()) {
    on<XpStatsRequested>(_onXpStatsRequested);
    on<LevelCalculationRequested>(_onLevelCalculationRequested);
    on<XpAwardedForHabit>(_onXpAwardedForHabit);
    on<XpAwardedForLogin>(_onXpAwardedForLogin);
    on<XpAwardedForAd>(_onXpAwardedForAd);
  }

  Future<void> _onXpStatsRequested(
    XpStatsRequested event,
    Emitter<XpState> emit,
  ) async {
    try {
      emit(XpLoading());

      final result = await _calculateLevel.execute(userId: event.userId);

      result.fold(
        (failure) {
          AppLogger.error('XpBloc: Stats load failed', failure);
          emit(XpError(failure.message));
        },
        (levelResult) {
          AppLogger.debug('XpBloc: Level ${levelResult.currentLevel}');
          emit(
            XpStatsLoaded(
              totalXp: levelResult.totalXp,
              currentLevel: levelResult.currentLevel,
              progressToNextLevel: levelResult.progressToNextLevel,
              xpToNextLevel: levelResult.xpRemainingForNextLevel,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('XpBloc: Stats error', e, stackTrace);
      emit(XpError(e.toString()));
    }
  }

  Future<void> _onLevelCalculationRequested(
    LevelCalculationRequested event,
    Emitter<XpState> emit,
  ) async {
    try {
      final result = await _calculateLevel.execute(userId: event.userId);

      result.fold((failure) => emit(XpError(failure.message)), (levelResult) {
        if (state is XpStatsLoaded) {
          final current = state as XpStatsLoaded;
          if (levelResult.currentLevel > current.currentLevel) {
            AppLogger.info(
              'XpBloc: Level up! Level ${levelResult.currentLevel}',
            );
            emit(
              LevelUp(
                newLevel: levelResult.currentLevel,
                totalXp: levelResult.totalXp,
              ),
            );
          }
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('XpBloc: Level calculation error', e, stackTrace);
      emit(XpError(e.toString()));
    }
  }

  Future<void> _onXpAwardedForHabit(
    XpAwardedForHabit event,
    Emitter<XpState> emit,
  ) async {
    try {
      final result = await _awardXp.forHabitCompletion(
        userId: event.userId,
        habitId: event.habitId,
      );

      result.fold(
        (failure) {
          AppLogger.error('XpBloc: Habit XP award failed', failure);
          emit(XpError(failure.message));
        },
        (xpResult) {
          AppLogger.info('XpBloc: Awarded ${xpResult.xpAwarded} XP for habit');
          emit(
            XpAwarded(
              xpAmount: xpResult.xpAwarded,
              hadBonus: xpResult.hasBonus,
              bonusType: xpResult.bonusType,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('XpBloc: Habit XP error', e, stackTrace);
      emit(XpError(e.toString()));
    }
  }

  Future<void> _onXpAwardedForLogin(
    XpAwardedForLogin event,
    Emitter<XpState> emit,
  ) async {
    try {
      final result = await _awardXp.forDailyLogin(userId: event.userId);

      result.fold((failure) => emit(XpError(failure.message)), (xpAmount) {
        AppLogger.info('XpBloc: Awarded $xpAmount XP for login');
        emit(XpAwarded(xpAmount: xpAmount, hadBonus: false));
      });
    } catch (e, stackTrace) {
      AppLogger.error('XpBloc: Login XP error', e, stackTrace);
      emit(XpError(e.toString()));
    }
  }

  Future<void> _onXpAwardedForAd(
    XpAwardedForAd event,
    Emitter<XpState> emit,
  ) async {
    try {
      final result = await _awardXp.forRewardedAd(
        userId: event.userId,
        adId: event.adId,
      );

      result.fold((failure) => emit(XpError(failure.message)), (xpAmount) {
        AppLogger.info('XpBloc: Awarded $xpAmount XP for ad');
        emit(XpAwarded(xpAmount: xpAmount, hadBonus: false));
      });
    } catch (e, stackTrace) {
      AppLogger.error('XpBloc: Ad XP error', e, stackTrace);
      emit(XpError(e.toString()));
    }
  }
}
