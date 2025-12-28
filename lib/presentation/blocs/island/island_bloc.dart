import 'package:flutter_bloc/flutter_bloc.dart';
import 'island_event.dart';
import 'island_state.dart';
import '../../../data/repositories/island_repository.dart';
import '../../../core/utils/app_logger.dart';

class IslandBloc extends Bloc<IslandEvent, IslandState> {
  final IslandRepository _repository;

  IslandBloc({required IslandRepository repository})
    : _repository = repository,
      super(IslandInitial()) {
    on<IslandLoadRequested>(_onIslandLoadRequested);
    on<IslandUpdateRequested>(_onIslandUpdateRequested);
    on<ZoneUnlockRequested>(_onZoneUnlockRequested);
    on<AchievementUnlockRequested>(_onAchievementUnlockRequested);
    on<WeatherUpdateRequested>(_onWeatherUpdateRequested);
  }

  Future<void> _onIslandLoadRequested(
    IslandLoadRequested event,
    Emitter<IslandState> emit,
  ) async {
    try {
      emit(IslandLoading());

      final result = await _repository.getIsland(event.userId);

      result.fold(
        (failure) {
          AppLogger.error('IslandBloc: Load failed', failure);
          emit(IslandError(failure.message));
        },
        (island) {
          AppLogger.debug('IslandBloc: Island loaded');
          emit(IslandLoaded(island));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('IslandBloc: Load error', e, stackTrace);
      emit(IslandError(e.toString()));
    }
  }

  Future<void> _onIslandUpdateRequested(
    IslandUpdateRequested event,
    Emitter<IslandState> emit,
  ) async {
    try {
      emit(IslandLoading());

      final result = await _repository.updateIsland(
        islandId: event.islandId,
        name: event.name,
      );

      result.fold((failure) => emit(IslandError(failure.message)), (island) {
        AppLogger.info('IslandBloc: Island updated');
        emit(IslandUpdated(island));
      });
    } catch (e, stackTrace) {
      AppLogger.error('IslandBloc: Update error', e, stackTrace);
      emit(IslandError(e.toString()));
    }
  }

  Future<void> _onZoneUnlockRequested(
    ZoneUnlockRequested event,
    Emitter<IslandState> emit,
  ) async {
    try {
      emit(IslandLoading());

      final result = await _repository.unlockZone(
        userId: event.userId,
        zoneId: event.zoneId,
      );

      result.fold((failure) => emit(IslandError(failure.message)), (_) {
        AppLogger.info('IslandBloc: Zone unlocked - ${event.zoneId}');
        emit(ZoneUnlocked(event.zoneId));
      });
    } catch (e, stackTrace) {
      AppLogger.error('IslandBloc: Unlock zone error', e, stackTrace);
      emit(IslandError(e.toString()));
    }
  }

  Future<void> _onAchievementUnlockRequested(
    AchievementUnlockRequested event,
    Emitter<IslandState> emit,
  ) async {
    try {
      final result = await _repository.unlockAchievement(
        userId: event.userId,
        achievementId: event.achievementId,
      );

      result.fold((failure) => emit(IslandError(failure.message)), (_) {
        AppLogger.info(
          'IslandBloc: Achievement unlocked - ${event.achievementId}',
        );
        emit(AchievementUnlocked(event.achievementId));
      });
    } catch (e, stackTrace) {
      AppLogger.error('IslandBloc: Unlock achievement error', e, stackTrace);
      emit(IslandError(e.toString()));
    }
  }

  Future<void> _onWeatherUpdateRequested(
    WeatherUpdateRequested event,
    Emitter<IslandState> emit,
  ) async {
    try {
      final result = await _repository.updateWeather(
        userId: event.userId,
        completionPercentage: event.completionPercentage,
      );

      result.fold(
        (failure) {
          AppLogger.error('IslandBloc: Weather update failed', failure);
          emit(IslandError(failure.message));
        },
        (island) {
          AppLogger.debug('IslandBloc: Weather updated');
          emit(IslandLoaded(island));
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('IslandBloc: Weather update error', e, stackTrace);
      emit(IslandError(e.toString()));
    }
  }
}
