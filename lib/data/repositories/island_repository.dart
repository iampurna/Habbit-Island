import 'package:dartz/dartz.dart';
import '../../domain/entities/island_state.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../services/storage_service.dart';
import '../models/island_state_model.dart';
import '../../core/utils/app_logger.dart';

/// Island Repository
/// Manages island state with offline-first architecture
class IslandRepository {
  final StorageService _storageService;

  IslandRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============================================================================
  // ISLAND OPERATIONS
  // ============================================================================

  /// Get island for user
  Future<Either<Failure, IslandState>> getIsland(String userId) async {
    try {
      AppLogger.info('IslandRepository: Getting island for user: $userId');

      // Try to get from local cache first
      IslandStateModel? islandModel = await _storageService.getIsland(userId);

      if (islandModel == null) {
        // Fetch from remote
        islandModel = await _storageService.fetchIslandFromRemote(userId);

        if (islandModel == null) {
          // Create new island if doesn't exist
          islandModel = _createDefaultIsland(userId);
          await _storageService.saveIsland(islandModel);
          await _storageService.syncIslandToRemote(islandModel);
        } else {
          // Save to cache
          await _storageService.saveIsland(islandModel);
        }
      }

      AppLogger.info('IslandRepository: Island loaded successfully');
      return Right(islandModel.toEntity());
    } on CacheException catch (e) {
      AppLogger.error('IslandRepository: Cache error', e);
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      AppLogger.error('IslandRepository: Server error', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('IslandRepository: Unexpected error', e, stackTrace);
      return Left(ServerFailure('Failed to get island: ${e.toString()}'));
    }
  }

  /// Update island properties
  Future<Either<Failure, IslandState>> updateIsland({
    required String islandId,
    String? name,
  }) async {
    try {
      AppLogger.info('IslandRepository: Updating island: $islandId');

      // Get current island from cache
      final currentIsland = await _storageService.getIslandById(islandId);

      if (currentIsland == null) {
        return Left(CacheFailure('Island not found'));
      }

      // Update island
      final updatedIsland = currentIsland.copyWith(
        name: name ?? currentIsland.name,
        updatedAt: DateTime.now(),
        weatherCondition: currentIsland.currentWeather,
        completionPercentage: currentIsland.overallCompletionRate,
        unlockedZones: [],
        achievements: [],
      );

      // Save to local storage
      await _storageService.saveIsland(updatedIsland);

      // Queue for remote sync
      await _storageService.queueIslandSync(updatedIsland);

      AppLogger.info('IslandRepository: Island updated successfully');
      return Right(updatedIsland.toEntity());
    } on CacheException catch (e) {
      AppLogger.error('IslandRepository: Update cache error', e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('IslandRepository: Update error', e, stackTrace);
      return Left(ServerFailure('Failed to update island: ${e.toString()}'));
    }
  }

  /// Update island weather based on habit completion percentage
  Future<Either<Failure, IslandState>> updateWeather({
    required String userId,
    required double completionPercentage,
  }) async {
    try {
      AppLogger.info(
        'IslandRepository: Updating weather for user: $userId, completion: $completionPercentage%',
      );

      // Get current island
      final currentIsland = await _storageService.getIsland(userId);

      if (currentIsland == null) {
        return Left(CacheFailure('Island not found'));
      }

      // Calculate new weather condition based on completion percentage
      final newWeather = _calculateWeatherCondition(completionPercentage);

      // Update island with new weather
      final updatedIsland = currentIsland.copyWith(
        weatherCondition: newWeather,
        completionPercentage: completionPercentage,
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _storageService.saveIsland(updatedIsland);

      // Queue for remote sync
      await _storageService.queueIslandSync(updatedIsland);

      AppLogger.info('IslandRepository: Weather updated to: $newWeather');
      return Right(updatedIsland.toEntity());
    } on CacheException catch (e) {
      AppLogger.error('IslandRepository: Weather update cache error', e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('IslandRepository: Weather update error', e, stackTrace);
      return Left(ServerFailure('Failed to update weather: ${e.toString()}'));
    }
  }

  // ============================================================================
  // ZONE OPERATIONS
  // ============================================================================

  /// Unlock new zone
  Future<Either<Failure, void>> unlockZone({
    required String userId,
    required String zoneId,
  }) async {
    try {
      AppLogger.info(
        'IslandRepository: Unlocking zone: $zoneId for user: $userId',
      );

      // Get current island
      final currentIsland = await _storageService.getIsland(userId);

      if (currentIsland == null) {
        return Left(CacheFailure('Island not found'));
      }

      // Add zone to unlocked zones if not already unlocked
      final unlockedZones = List<String>.from(currentIsland.unlockedZones);
      if (!unlockedZones.contains(zoneId)) {
        unlockedZones.add(zoneId);

        // Update island
        final updatedIsland = currentIsland.copyWith(
          unlockedZones: unlockedZones,
          updatedAt: DateTime.now(),
          weatherCondition: currentIsland.currentWeather,
          completionPercentage: currentIsland.overallCompletionRate,
        );

        // Save to local storage
        await _storageService.saveIsland(updatedIsland);

        // Queue for remote sync
        await _storageService.queueIslandSync(updatedIsland);

        AppLogger.info('IslandRepository: Zone unlocked successfully');
      } else {
        AppLogger.info('IslandRepository: Zone already unlocked');
      }

      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('IslandRepository: Unlock zone cache error', e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('IslandRepository: Unlock zone error', e, stackTrace);
      return Left(ServerFailure('Failed to unlock zone: ${e.toString()}'));
    }
  }

  // ============================================================================
  // ACHIEVEMENT OPERATIONS
  // ============================================================================

  /// Unlock achievement
  Future<Either<Failure, void>> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      AppLogger.info(
        'IslandRepository: Unlocking achievement: $achievementId for user: $userId',
      );

      // Get current island
      final currentIsland = await _storageService.getIsland(userId);

      if (currentIsland == null) {
        return Left(CacheFailure('Island not found'));
      }

      // Add achievement to unlocked achievements if not already unlocked
      final achievements = List<String>.from(currentIsland.achievements);
      if (!achievements.contains(achievementId)) {
        achievements.add(achievementId);

        // Update island
        final updatedIsland = currentIsland.copyWith(
          achievements: achievements,
          updatedAt: DateTime.now(),
          weatherCondition: currentIsland.currentWeather,
          completionPercentage: currentIsland.overallCompletionRate,
          unlockedZones: [],
        );

        // Save to local storage
        await _storageService.saveIsland(updatedIsland);

        // Queue for remote sync
        await _storageService.queueIslandSync(updatedIsland);

        AppLogger.info('IslandRepository: Achievement unlocked successfully');
      } else {
        AppLogger.info('IslandRepository: Achievement already unlocked');
      }

      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('IslandRepository: Unlock achievement cache error', e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'IslandRepository: Unlock achievement error',
        e,
        stackTrace,
      );
      return Left(
        ServerFailure('Failed to unlock achievement: ${e.toString()}'),
      );
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Create default island for new user
  IslandStateModel _createDefaultIsland(String userId) {
    return IslandStateModel(
      id: 'island_$userId',
      userId: userId,
      name: 'My Island',
      totalXp: 0,
      currentLevel: 1,
      weatherCondition: WeatherCondition.sunny,
      unlockedZones: ['starter-beach'], // Default starting zone
      currentZone: 'starter-beach',
      achievements: [],
      completionPercentage: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Calculate weather condition based on completion percentage
  /// Spec: 100%=Rainbow, 75%=Sunny, 50%=Partly Cloudy, 25%=Cloudy, <25%=Stormy
  WeatherCondition _calculateWeatherCondition(double completionPercentage) {
    if (completionPercentage >= 100) {
      return WeatherCondition.rainbow;
    } else if (completionPercentage >= 75) {
      return WeatherCondition.sunny;
    } else if (completionPercentage >= 50) {
      return WeatherCondition.partlyCloudy;
    } else if (completionPercentage >= 25) {
      return WeatherCondition.cloudy;
    } else {
      return WeatherCondition.stormy;
    }
  }

  /// Calculate required XP for next level
  int calculateXpForNextLevel(int currentLevel) {
    // Progressive XP requirement (example formula)
    return currentLevel * 100 + 500;
  }

  /// Check if user can unlock zone
  Future<Either<Failure, bool>> canUnlockZone({
    required String userId,
    required String zoneId,
    required int requiredXp,
  }) async {
    try {
      final island = await _storageService.getIsland(userId);

      if (island == null) {
        return Left(CacheFailure('Island not found'));
      }

      // Check if already unlocked
      if (island.unlockedZones.contains(zoneId)) {
        return const Right(false);
      }

      // Check if user has enough XP
      final hasEnoughXp = island.totalXp >= requiredXp;

      return Right(hasEnoughXp);
    } catch (e, stackTrace) {
      AppLogger.error('IslandRepository: Can unlock zone error', e, stackTrace);
      return Left(
        ServerFailure('Failed to check zone unlock: ${e.toString()}'),
      );
    }
  }

  /// Update island XP (called when user earns XP)
  Future<Either<Failure, IslandState>> updateXp({
    required String userId,
    required int xpToAdd,
  }) async {
    try {
      AppLogger.info('IslandRepository: Adding $xpToAdd XP for user: $userId');

      // Get current island
      final currentIsland = await _storageService.getIsland(userId);

      if (currentIsland == null) {
        return Left(CacheFailure('Island not found'));
      }

      // Calculate new total XP
      final newTotalXp = currentIsland.totalXp + xpToAdd;

      // Calculate new level
      final newLevel = _calculateLevel(newTotalXp);

      // Update island
      final updatedIsland = currentIsland.copyWith(
        totalXp: newTotalXp,
        currentLevel: newLevel,
        updatedAt: DateTime.now(),
        weatherCondition: currentIsland.currentWeather,
        completionPercentage: currentIsland.overallCompletionRate,
        unlockedZones: List<String>.from(currentIsland.unlockedZones),
        achievements: List<String>.from(currentIsland.achievements),
      );

      // Save to local storage
      await _storageService.saveIsland(updatedIsland);

      // Queue for remote sync
      await _storageService.queueIslandSync(updatedIsland);

      AppLogger.info(
        'IslandRepository: XP updated, new total: $newTotalXp, level: $newLevel',
      );
      return Right(updatedIsland.toEntity());
    } on CacheException catch (e) {
      AppLogger.error('IslandRepository: Update XP cache error', e);
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('IslandRepository: Update XP error', e, stackTrace);
      return Left(ServerFailure('Failed to update XP: ${e.toString()}'));
    }
  }

  /// Calculate level from total XP
  int _calculateLevel(int totalXp) {
    // Simple level calculation (adjust formula as needed)
    // Level 1: 0-99 XP
    // Level 2: 100-299 XP
    // Level 3: 300-599 XP
    // Formula: level = floor(sqrt(totalXp / 100)) + 1
    if (totalXp < 100) return 1;
    return (totalXp / 100).floor() + 1;
  }
}
