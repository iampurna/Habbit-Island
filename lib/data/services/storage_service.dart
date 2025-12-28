import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../models/island_state_model.dart';
import '../models/xp_event_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/app_logger.dart';

/// Storage Service
/// Manages local Hive storage and remote Supabase synchronization
/// Implements offline-first architecture
class StorageService {
  // Hive Box Names
  static const String _habitsBox = 'habits';
  static const String _completionsBox = 'completions';
  static const String _streaksBox = 'streaks';
  static const String _userBox = 'user';
  static const String _premiumBox = 'premium';
  static const String _islandBox = 'island';
  static const String _xpEventsBox = 'xp_events';
  static const String _syncQueueBox = 'sync_queue';
  static const String _settingsBox = 'settings';

  // Supabase client
  late final SupabaseClient _supabase;

  // Hive boxes
  late final Box<Map> _habitsHive;
  late final Box<Map> _completionsHive;
  late final Box<Map> _streaksHive;
  late final Box<Map> _userHive;
  late final Box<Map> _premiumHive;
  late final Box<Map> _islandHive;
  late final Box<Map> _xpEventsHive;
  late final Box<Map> _syncQueueHive;
  late final Box<Map> _settingsHive;

  bool _initialized = false;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize Hive boxes and Supabase
  Future<void> init() async {
    if (_initialized) {
      AppLogger.warning('StorageService: Already initialized');
      return;
    }

    try {
      AppLogger.info('StorageService: Initializing...');

      // Initialize Supabase
      await _initializeSupabase();

      // Open all Hive boxes
      await _openHiveBoxes();

      _initialized = true;
      AppLogger.info('StorageService: Initialization complete');
    } catch (e, stackTrace) {
      AppLogger.error('StorageService: Initialization failed', e, stackTrace);
      throw CacheException('Failed to initialize storage: ${e.toString()}');
    }
  }

  /// Initialize Supabase client
  Future<void> _initializeSupabase() async {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        AppLogger.warning(
          'StorageService: Supabase credentials not found in .env',
        );
        throw CacheException('Supabase credentials missing');
      }

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      _supabase = Supabase.instance.client;
      AppLogger.info('StorageService: Supabase initialized');
    } catch (e) {
      AppLogger.error('StorageService: Supabase init failed', e);
      rethrow;
    }
  }

  /// Open all Hive boxes
  Future<void> _openHiveBoxes() async {
    try {
      _habitsHive = await Hive.openBox<Map>(_habitsBox);
      _completionsHive = await Hive.openBox<Map>(_completionsBox);
      _streaksHive = await Hive.openBox<Map>(_streaksBox);
      _userHive = await Hive.openBox<Map>(_userBox);
      _premiumHive = await Hive.openBox<Map>(_premiumBox);
      _islandHive = await Hive.openBox<Map>(_islandBox);
      _xpEventsHive = await Hive.openBox<Map>(_xpEventsBox);
      _syncQueueHive = await Hive.openBox<Map>(_syncQueueBox);
      _settingsHive = await Hive.openBox<Map>(_settingsBox);

      AppLogger.info('StorageService: All Hive boxes opened');
    } catch (e) {
      AppLogger.error('StorageService: Failed to open Hive boxes', e);
      rethrow;
    }
  }

  // ============================================================================
  // USER OPERATIONS
  // ============================================================================

  /// Save user to local storage
  Future<void> saveUser(UserModel user) async {
    try {
      await _userHive.put(user.id, user.toJson());
      AppLogger.debug('StorageService: User saved to cache: ${user.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to save user', e);
      throw CacheException('Failed to save user: ${e.toString()}');
    }
  }

  /// Get user from local storage
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = _userHive.get(userId);
      if (data != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      AppLogger.error('StorageService: Failed to get user', e);
      throw CacheException('Failed to get user: ${e.toString()}');
    }
  }

  /// Sync user to remote Supabase
  Future<void> syncUserToRemote(UserModel user) async {
    try {
      await _supabase.from('users').upsert(user.toJson());
      AppLogger.debug('StorageService: User synced to remote: ${user.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to sync user to remote', e);
      // Queue for retry
      await _queueSyncOperation('user', user.id, 'upsert', user.toJson());
    }
  }

  /// Fetch user from remote Supabase
  Future<UserModel?> fetchUserFromRemote(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      AppLogger.error('StorageService: Failed to fetch user from remote', e);
      throw ServerException('Failed to fetch user: ${e.toString()}');
    }
  }

  /// Clear user data (for logout)
  Future<void> clearUserData() async {
    try {
      await _userHive.clear();
      await _habitsHive.clear();
      await _completionsHive.clear();
      await _streaksHive.clear();
      await _islandHive.clear();
      await _xpEventsHive.clear();
      await _premiumHive.clear();
      AppLogger.info('StorageService: User data cleared');
    } catch (e) {
      AppLogger.error('StorageService: Failed to clear user data', e);
      throw CacheException('Failed to clear data: ${e.toString()}');
    }
  }

  // ============================================================================
  // HABIT OPERATIONS
  // ============================================================================

  /// Save habit to local storage
  Future<void> saveHabit(HabitModel habit) async {
    try {
      await _habitsHive.put(habit.id, habit.toJson());
      AppLogger.debug('StorageService: Habit saved: ${habit.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to save habit', e);
      throw CacheException('Failed to save habit: ${e.toString()}');
    }
  }

  /// Get habit by ID
  Future<HabitModel?> getHabit(String habitId) async {
    try {
      final data = _habitsHive.get(habitId);
      if (data != null) {
        return HabitModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      AppLogger.error('StorageService: Failed to get habit', e);
      throw CacheException('Failed to get habit: ${e.toString()}');
    }
  }

  /// Get all habits for user
  Future<List<HabitModel>> getHabits(
    String userId, {
    bool activeOnly = false,
  }) async {
    try {
      final allHabits = _habitsHive.values
          .map((data) => HabitModel.fromJson(Map<String, dynamic>.from(data)))
          .where((habit) => habit.userId == userId)
          .toList();

      if (activeOnly) {
        return allHabits.where((habit) => habit.isActive).toList();
      }

      return allHabits;
    } catch (e) {
      AppLogger.error('StorageService: Failed to get habits', e);
      throw CacheException('Failed to get habits: ${e.toString()}');
    }
  }

  /// Delete habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsHive.delete(habitId);
      AppLogger.debug('StorageService: Habit deleted: $habitId');
    } catch (e) {
      AppLogger.error('StorageService: Failed to delete habit', e);
      throw CacheException('Failed to delete habit: ${e.toString()}');
    }
  }

  /// Sync habit to remote
  Future<void> syncHabitToRemote(HabitModel habit) async {
    try {
      await _supabase.from('habits').upsert(habit.toJson());
      AppLogger.debug('StorageService: Habit synced to remote: ${habit.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to sync habit to remote', e);
      await _queueSyncOperation('habit', habit.id, 'upsert', habit.toJson());
    }
  }

  // ============================================================================
  // COMPLETION OPERATIONS
  // ============================================================================

  /// Save completion
  Future<void> saveCompletion(HabitCompletionModel completion) async {
    try {
      await _completionsHive.put(completion.id, completion.toJson());
      AppLogger.debug('StorageService: Completion saved: ${completion.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to save completion', e);
      throw CacheException('Failed to save completion: ${e.toString()}');
    }
  }

  /// Get completions for habit
  Future<List<HabitCompletionModel>> getCompletions(String habitId) async {
    try {
      return _completionsHive.values
          .map(
            (data) =>
                HabitCompletionModel.fromJson(Map<String, dynamic>.from(data)),
          )
          .where((completion) => completion.habitId == habitId)
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (e) {
      AppLogger.error('StorageService: Failed to get completions', e);
      throw CacheException('Failed to get completions: ${e.toString()}');
    }
  }

  /// Sync completion to remote
  Future<void> syncCompletionToRemote(HabitCompletionModel completion) async {
    try {
      await _supabase.from('habit_completions').upsert(completion.toJson());
      AppLogger.debug('StorageService: Completion synced: ${completion.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to sync completion', e);
      await _queueSyncOperation(
        'completion',
        completion.id,
        'upsert',
        completion.toJson(),
      );
    }
  }

  // ============================================================================
  // ISLAND OPERATIONS
  // ============================================================================

  /// Save island state
  Future<void> saveIsland(IslandStateModel island) async {
    try {
      await _islandHive.put(island.userId, island.toJson());
      AppLogger.debug(
        'StorageService: Island saved for user: ${island.userId}',
      );
    } catch (e) {
      AppLogger.error('StorageService: Failed to save island', e);
      throw CacheException('Failed to save island: ${e.toString()}');
    }
  }

  /// Get island by user ID
  Future<IslandStateModel?> getIsland(String userId) async {
    try {
      final data = _islandHive.get(userId);
      if (data != null) {
        return IslandStateModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      AppLogger.error('StorageService: Failed to get island', e);
      throw CacheException('Failed to get island: ${e.toString()}');
    }
  }

  /// Get island by island ID
  Future<IslandStateModel?> getIslandById(String islandId) async {
    try {
      for (final data in _islandHive.values) {
        final island = IslandStateModel.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (island.id == islandId) {
          return island;
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('StorageService: Failed to get island by ID', e);
      throw CacheException('Failed to get island: ${e.toString()}');
    }
  }

  /// Fetch island from remote
  Future<IslandStateModel?> fetchIslandFromRemote(String userId) async {
    try {
      final response = await _supabase
          .from('island_states')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return IslandStateModel.fromJson(response);
      }
      return null;
    } catch (e) {
      AppLogger.error('StorageService: Failed to fetch island from remote', e);
      throw ServerException('Failed to fetch island: ${e.toString()}');
    }
  }

  /// Sync island to remote
  Future<void> syncIslandToRemote(IslandStateModel island) async {
    try {
      await _supabase.from('island_states').upsert(island.toJson());
      AppLogger.debug('StorageService: Island synced to remote: ${island.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to sync island to remote', e);
      await _queueSyncOperation('island', island.id, 'upsert', island.toJson());
    }
  }

  /// Queue island for sync
  Future<void> queueIslandSync(IslandStateModel island) async {
    await _queueSyncOperation('island', island.id, 'upsert', island.toJson());
  }

  // ============================================================================
  // XP EVENTS OPERATIONS
  // ============================================================================

  /// Save XP event
  Future<void> saveXpEvent(XpEventModel event) async {
    try {
      await _xpEventsHive.put(event.id, event.toJson());
      AppLogger.debug('StorageService: XP event saved: ${event.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to save XP event', e);
      throw CacheException('Failed to save XP event: ${e.toString()}');
    }
  }

  /// Get XP events for user
  Future<List<XpEventModel>> getXpEvents(String userId) async {
    try {
      return _xpEventsHive.values
          .map((data) => XpEventModel.fromJson(Map<String, dynamic>.from(data)))
          .where((event) => event.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      AppLogger.error('StorageService: Failed to get XP events', e);
      throw CacheException('Failed to get XP events: ${e.toString()}');
    }
  }

  /// Sync XP event to remote
  Future<void> syncXpEventToRemote(XpEventModel event) async {
    try {
      await _supabase.from('xp_events').insert(event.toJson());
      AppLogger.debug('StorageService: XP event synced: ${event.id}');
    } catch (e) {
      AppLogger.error('StorageService: Failed to sync XP event', e);
      await _queueSyncOperation('xp_event', event.id, 'insert', event.toJson());
    }
  }

  // ============================================================================
  // SYNC QUEUE OPERATIONS
  // ============================================================================

  /// Queue sync operation for later
  Future<void> _queueSyncOperation(
    String type,
    String itemId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      final queueItem = {
        'type': type,
        'item_id': itemId,
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'retry_count': 0,
      };

      await _syncQueueHive.put('${type}_$itemId', queueItem);
      AppLogger.debug(
        'StorageService: Queued sync operation: $type $operation',
      );
    } catch (e) {
      AppLogger.error('StorageService: Failed to queue sync operation', e);
    }
  }

  /// Process sync queue
  Future<int> processSyncQueue() async {
    int synced = 0;

    try {
      final items = _syncQueueHive.values.toList();

      for (final item in items) {
        final data = Map<String, dynamic>.from(item);
        final type = data['type'] as String;
        final operation = data['operation'] as String;
        final itemData = Map<String, dynamic>.from(data['data']);

        try {
          // Perform sync based on type
          if (operation == 'upsert') {
            await _supabase.from('${type}s').upsert(itemData);
          } else if (operation == 'insert') {
            await _supabase.from('${type}s').insert(itemData);
          } else if (operation == 'delete') {
            await _supabase.from('${type}s').delete().eq('id', data['item_id']);
          }

          // Remove from queue on success
          await _syncQueueHive.delete('${type}_${data['item_id']}');
          synced++;
        } catch (e) {
          AppLogger.error('StorageService: Sync queue item failed', e);
          // Increment retry count
          data['retry_count'] = (data['retry_count'] ?? 0) + 1;

          if (data['retry_count'] >= 3) {
            // Remove after 3 retries
            await _syncQueueHive.delete('${type}_${data['item_id']}');
          } else {
            await _syncQueueHive.put('${type}_${data['item_id']}', data);
          }
        }
      }

      AppLogger.info('StorageService: Processed $synced items from sync queue');
    } catch (e) {
      AppLogger.error('StorageService: Failed to process sync queue', e);
    }

    return synced;
  }

  // ============================================================================
  // SETTINGS OPERATIONS
  // ============================================================================

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsHive.put(key, {'value': value});
    } catch (e) {
      AppLogger.error('StorageService: Failed to save setting', e);
    }
  }

  /// Get setting
  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    try {
      final data = _settingsHive.get(key);
      if (data != null) {
        return data['value'] as T?;
      }
      return defaultValue;
    } catch (e) {
      AppLogger.error('StorageService: Failed to get setting', e);
      return defaultValue;
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Close all boxes
  Future<void> close() async {
    await _habitsHive.close();
    await _completionsHive.close();
    await _streaksHive.close();
    await _userHive.close();
    await _premiumHive.close();
    await _islandHive.close();
    await _xpEventsHive.close();
    await _syncQueueHive.close();
    await _settingsHive.close();
    _initialized = false;
    AppLogger.info('StorageService: All boxes closed');
  }
}
