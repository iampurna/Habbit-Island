import 'package:habbit_island/core/errors/exceptions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Hive Database Manager
/// Handles Hive initialization, box management, and type adapter registration
/// Reference: Technical Addendum §2.1 (Offline-First Architecture)

class HiveDatabase {
  // Singleton pattern
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  // Box names
  static const String habitsBox = 'habits_box';
  static const String completionsBox = 'completions_box';
  static const String streaksBox = 'streaks_box';
  static const String userBox = 'user_box';
  static const String premiumBox = 'premium_box';
  static const String islandBox = 'island_box';
  static const String xpEventsBox = 'xp_events_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String settingsBox = 'settings_box';

  bool _isInitialized = false;

  /// Initialize Hive with Flutter
  /// Call this in main() before runApp()
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Get application documents directory for custom path (optional)
      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);

      // Register all type adapters
      _registerAdapters();

      // Open all boxes
      await _openBoxes();

      _isInitialized = true;
    } catch (e) {
      throw CacheException('Failed to initialize Hive: $e');
    }
  }

  /// Register all Hive type adapters
  /// These convert Dart objects to/from binary format for storage
  void _registerAdapters() {
    // Note: Type adapters need to be generated using build_runner
    // Add to your pubspec.yaml:
    // dependencies:
    //   hive: ^2.2.3
    //   hive_flutter: ^1.1.0
    // dev_dependencies:
    //   hive_generator: ^2.0.0
    //   build_runner: ^2.4.0

    // Then annotate your models with @HiveType and run:
    // flutter packages pub run build_runner build

    // For now, we'll use JSON serialization approach (no type adapters needed)
    // This is simpler and works well for most cases
    // If you need better performance, use type adapters later
  }

  /// Open all Hive boxes
  Future<void> _openBoxes() async {
    try {
      await Future.wait([
        Hive.openBox(habitsBox),
        Hive.openBox(completionsBox),
        Hive.openBox(streaksBox),
        Hive.openBox(userBox),
        Hive.openBox(premiumBox),
        Hive.openBox(islandBox),
        Hive.openBox(xpEventsBox),
        Hive.openBox(syncQueueBox),
        Hive.openBox(settingsBox),
      ]);
    } catch (e) {
      throw CacheException('Failed to open Hive boxes: $e');
    }
  }

  /// Get a specific box
  Box<dynamic> getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw CacheException('Box $boxName is not open');
    }
    return Hive.box(boxName);
  }

  /// Get habits box
  Box<dynamic> get habits => getBox(habitsBox);

  /// Get completions box
  Box<dynamic> get completions => getBox(completionsBox);

  /// Get streaks box
  Box<dynamic> get streaks => getBox(streaksBox);

  /// Get user box
  Box<dynamic> get user => getBox(userBox);

  /// Get premium box
  Box<dynamic> get premium => getBox(premiumBox);

  /// Get island box
  Box<dynamic> get island => getBox(islandBox);

  /// Get XP events box
  Box<dynamic> get xpEvents => getBox(xpEventsBox);

  /// Get sync queue box
  Box<dynamic> get syncQueue => getBox(syncQueueBox);

  /// Get settings box
  Box<dynamic> get settings => getBox(settingsBox);

  /// Clear all data (for logout/reset)
  Future<void> clearAll() async {
    try {
      await Future.wait([
        habits.clear(),
        completions.clear(),
        streaks.clear(),
        user.clear(),
        premium.clear(),
        island.clear(),
        xpEvents.clear(),
        syncQueue.clear(),
        // Don't clear settings - preserve user preferences
      ]);
    } catch (e) {
      throw CacheException('Failed to clear Hive data: $e');
    }
  }

  /// Clear specific box
  Future<void> clearBox(String boxName) async {
    try {
      await getBox(boxName).clear();
    } catch (e) {
      throw CacheException('Failed to clear box $boxName: $e');
    }
  }

  /// Close all boxes (call on app shutdown)
  Future<void> close() async {
    try {
      await Hive.close();
      _isInitialized = false;
    } catch (e) {
      throw CacheException('Failed to close Hive: $e');
    }
  }

  /// Compact all boxes (optimize storage)
  Future<void> compact() async {
    try {
      await Future.wait([
        habits.compact(),
        completions.compact(),
        streaks.compact(),
        user.compact(),
        premium.compact(),
        island.compact(),
        xpEvents.compact(),
        syncQueue.compact(),
        settings.compact(),
      ]);
    } catch (e) {
      throw CacheException('Failed to compact Hive boxes: $e');
    }
  }

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      int totalSize = 0;

      final boxNames = [
        habitsBox,
        completionsBox,
        streaksBox,
        userBox,
        premiumBox,
        islandBox,
        xpEventsBox,
        syncQueueBox,
        settingsBox,
      ];

      for (final boxName in boxNames) {
        final file = File('${dir.path}/$boxName.hive');
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Check if database needs compaction (>10MB)
  Future<bool> needsCompaction() async {
    final size = await getDatabaseSize();
    return size > 10 * 1024 * 1024; // 10MB
  }
}
