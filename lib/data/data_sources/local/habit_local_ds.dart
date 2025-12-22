import 'dart:convert';
import 'package:habbit_island/data/models/habit_model.dart';
import 'hive_database.dart';

/// Habit Local Data Source
/// Handles local storage of habits using Hive
/// Reference: Technical Addendum §2.1 (Offline-First Architecture)

class HabitLocalDataSource {
  final HiveDatabase _hiveDb;

  HabitLocalDataSource(this._hiveDb);

  /// Get all habits for user
  Future<List<HabitModel>> getAllHabits(String userId) async {
    try {
      final box = _hiveDb.habits;
      final habits = <HabitModel>[];

      for (final key in box.keys) {
        final json = jsonDecode(box.get(key) as String) as Map<String, dynamic>;
        final habit = HabitModel.fromJson(json);

        if (habit.userId == userId) {
          habits.add(habit);
        }
      }

      return habits;
    } catch (e) {
      throw CacheException('Failed to get habits: $e');
    }
  }

  /// Get habit by ID
  Future<HabitModel?> getHabit(String habitId) async {
    try {
      final box = _hiveDb.habits;
      final jsonString = box.get(habitId) as String?;

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HabitModel.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get habit: $e');
    }
  }

  /// Get active habits for user
  Future<List<HabitModel>> getActiveHabits(String userId) async {
    try {
      final allHabits = await getAllHabits(userId);
      return allHabits.where((h) => h.isActive).toList();
    } catch (e) {
      throw CacheException('Failed to get active habits: $e');
    }
  }

  /// Get habits by zone
  Future<List<HabitModel>> getHabitsByZone(String userId, String zoneId) async {
    try {
      final allHabits = await getAllHabits(userId);
      return allHabits.where((h) => h.zoneId == zoneId).toList();
    } catch (e) {
      throw CacheException('Failed to get habits by zone: $e');
    }
  }

  /// Get habits by category
  Future<List<HabitModel>> getHabitsByCategory(
    String userId,
    HabitCategory category,
  ) async {
    try {
      final allHabits = await getAllHabits(userId);
      return allHabits.where((h) => h.category == category).toList();
    } catch (e) {
      throw CacheException('Failed to get habits by category: $e');
    }
  }

  /// Save habit (create or update)
  Future<void> saveHabit(HabitModel habit) async {
    try {
      final box = _hiveDb.habits;
      final jsonString = jsonEncode(habit.toJson());
      await box.put(habit.id, jsonString);
    } catch (e) {
      throw CacheException('Failed to save habit: $e');
    }
  }

  /// Save multiple habits
  Future<void> saveHabits(List<HabitModel> habits) async {
    try {
      final box = _hiveDb.habits;
      final entries = <String, String>{};

      for (final habit in habits) {
        entries[habit.id] = jsonEncode(habit.toJson());
      }

      await box.putAll(entries);
    } catch (e) {
      throw CacheException('Failed to save habits: $e');
    }
  }

  /// Update habit
  Future<void> updateHabit(HabitModel habit) async {
    try {
      final updatedHabit = habit.copyWith(updatedAt: DateTime.now());
      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to update habit: $e');
    }
  }

  /// Delete habit
  Future<void> deleteHabit(String habitId) async {
    try {
      final box = _hiveDb.habits;
      await box.delete(habitId);
    } catch (e) {
      throw CacheException('Failed to delete habit: $e');
    }
  }

  /// Soft delete habit (set isActive = false)
  Future<void> softDeleteHabit(String habitId) async {
    try {
      final habit = await getHabit(habitId);
      if (habit == null) {
        throw NotFoundException('Habit not found: $habitId');
      }

      final updatedHabit = habit.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to soft delete habit: $e');
    }
  }

  /// Update habit streak
  Future<void> updateHabitStreak(
    String habitId,
    int currentStreak,
    int longestStreak,
    DateTime? lastCompletedAt,
  ) async {
    try {
      final habit = await getHabit(habitId);
      if (habit == null) {
        throw NotFoundException('Habit not found: $habitId');
      }

      final updatedHabit = habit.copyWith(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedAt: lastCompletedAt,
        updatedAt: DateTime.now(),
      );

      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to update habit streak: $e');
    }
  }

  /// Increment habit completion count
  Future<void> incrementCompletionCount(String habitId) async {
    try {
      final habit = await getHabit(habitId);
      if (habit == null) {
        throw NotFoundException('Habit not found: $habitId');
      }

      final updatedHabit = habit.copyWith(
        totalCompletions: habit.totalCompletions + 1,
        lastCompletedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to increment completion count: $e');
    }
  }

  /// Update habit decay state
  Future<void> updateDecayState(String habitId, DecayState decayState) async {
    try {
      final habit = await getHabit(habitId);
      if (habit == null) {
        throw NotFoundException('Habit not found: $habitId');
      }

      final updatedHabit = habit.copyWith(
        decayState: decayState,
        updatedAt: DateTime.now(),
      );

      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to update decay state: $e');
    }
  }

  /// Update habit growth level
  Future<void> updateGrowthLevel(
    String habitId,
    GrowthLevel growthLevel,
  ) async {
    try {
      final habit = await getHabit(habitId);
      if (habit == null) {
        throw NotFoundException('Habit not found: $habitId');
      }

      final updatedHabit = habit.copyWith(
        growthLevel: growthLevel,
        updatedAt: DateTime.now(),
      );

      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to update growth level: $e');
    }
  }

  /// Check if habit name exists for user
  Future<bool> habitNameExists(
    String userId,
    String name, {
    String? excludeId,
  }) async {
    try {
      final habits = await getAllHabits(userId);
      return habits.any(
        (h) => h.name.toLowerCase() == name.toLowerCase() && h.id != excludeId,
      );
    } catch (e) {
      throw CacheException('Failed to check habit name: $e');
    }
  }

  /// Count habits for user
  Future<int> countHabits(String userId, {bool activeOnly = false}) async {
    try {
      final habits = await getAllHabits(userId);
      if (activeOnly) {
        return habits.where((h) => h.isActive).length;
      }
      return habits.length;
    } catch (e) {
      throw CacheException('Failed to count habits: $e');
    }
  }

  /// Count habits in zone
  Future<int> countHabitsInZone(String userId, String zoneId) async {
    try {
      final habits = await getHabitsByZone(userId, zoneId);
      return habits.where((h) => h.isActive).length;
    } catch (e) {
      throw CacheException('Failed to count habits in zone: $e');
    }
  }

  /// Get habits that need sync
  Future<List<HabitModel>> getHabitsNeedingSync(String userId) async {
    try {
      final habits = await getAllHabits(userId);
      return habits.where((h) {
        // Habit needs sync if:
        // 1. Never synced (lastSyncedAt is null)
        // 2. Updated after last sync
        if (h.lastSyncedAt == null) return true;
        return h.updatedAt.isAfter(h.lastSyncedAt!);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get habits needing sync: $e');
    }
  }

  /// Mark habit as synced
  Future<void> markHabitAsSynced(String habitId) async {
    try {
      final habit = await getHabit(habitId);
      if (habit == null) return;

      final updatedHabit = habit.copyWith(lastSyncedAt: DateTime.now());

      await saveHabit(updatedHabit);
    } catch (e) {
      throw CacheException('Failed to mark habit as synced: $e');
    }
  }

  /// Clear all habits for user
  Future<void> clearHabits(String userId) async {
    try {
      final box = _hiveDb.habits;
      final keysToDelete = <String>[];

      for (final key in box.keys) {
        final jsonString = box.get(key) as String;
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final habit = HabitModel.fromJson(json);

        if (habit.userId == userId) {
          keysToDelete.add(key as String);
        }
      }

      await box.deleteAll(keysToDelete);
    } catch (e) {
      throw CacheException('Failed to clear habits: $e');
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await _hiveDb.habits.clear();
    } catch (e) {
      throw CacheException('Failed to clear all habits: $e');
    }
  }
}

/// Custom exceptions (reference your existing exception files)
class CacheException implements Exception {
  final String message;
  final String? code;

  const CacheException(this.message, {this.code});

  @override
  String toString() =>
      'CacheException: $message ${code != null ? '(Code: $code)' : ''}';
}

class NotFoundException implements Exception {
  final String message;
  final String? code;

  const NotFoundException(this.message, {this.code});

  @override
  String toString() =>
      'NotFoundException: $message ${code != null ? '(Code: $code)' : ''}';
}
