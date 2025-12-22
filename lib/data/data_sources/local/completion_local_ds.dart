import 'dart:convert';
import 'package:habbit_island/data/models/habit_completion_model.dart';
import 'package:habbit_island/data/models/habit_streak_model.dart';
import 'package:habbit_island/data/models/island_state_model.dart';
import 'package:habbit_island/data/models/xp_event_model.dart';

import 'hive_database.dart';

/// Completions, Streaks, XP & Island Local Data Source
class CompletionsLocalDataSource {
  final HiveDatabase _hiveDb;

  CompletionsLocalDataSource(this._hiveDb);

  // COMPLETIONS
  Future<List<HabitCompletionModel>> getCompletions(String habitId) async {
    try {
      final box = _hiveDb.completions;
      final completions = <HabitCompletionModel>[];

      for (final key in box.keys) {
        final json = jsonDecode(box.get(key) as String) as Map<String, dynamic>;
        final completion = HabitCompletionModel.fromJson(json);

        if (completion.habitId == habitId) {
          completions.add(completion);
        }
      }

      completions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return completions;
    } catch (e) {
      throw CacheException('Failed to get completions: $e');
    }
  }

  Future<HabitCompletionModel?> getCompletion(String id) async {
    try {
      final box = _hiveDb.completions;
      final jsonString = box.get(id) as String?;
      if (jsonString == null) return null;
      return HabitCompletionModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException('Failed to get completion: $e');
    }
  }

  Future<void> saveCompletion(HabitCompletionModel completion) async {
    try {
      await _hiveDb.completions.put(
        completion.id,
        jsonEncode(completion.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to save completion: $e');
    }
  }

  Future<void> deleteCompletion(String id) async {
    try {
      await _hiveDb.completions.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete completion: $e');
    }
  }

  Future<List<HabitCompletionModel>> getCompletionsByDate(
    String habitId,
    DateTime date,
  ) async {
    try {
      final all = await getCompletions(habitId);
      final targetDate = DateTime(date.year, date.month, date.day);
      return all.where((c) {
        final logicalDate = DateTime(
          c.logicalDate.year,
          c.logicalDate.month,
          c.logicalDate.day,
        );
        return logicalDate.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get completions by date: $e');
    }
  }

  // STREAKS
  Future<HabitStreakModel?> getStreak(String habitId) async {
    try {
      final box = _hiveDb.streaks;
      final jsonString = box.get(habitId) as String?;
      if (jsonString == null) return null;
      return HabitStreakModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException('Failed to get streak: $e');
    }
  }

  Future<void> saveStreak(HabitStreakModel streak) async {
    try {
      await _hiveDb.streaks.put(streak.habitId, jsonEncode(streak.toJson()));
    } catch (e) {
      throw CacheException('Failed to save streak: $e');
    }
  }

  // XP EVENTS
  Future<List<XpEventModel>> getXpEvents(String userId) async {
    try {
      final box = _hiveDb.xpEvents;
      final events = <XpEventModel>[];

      for (final key in box.keys) {
        final json = jsonDecode(box.get(key) as String) as Map<String, dynamic>;
        final event = XpEventModel.fromJson(json);

        if (event.userId == userId) {
          events.add(event);
        }
      }

      events.sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
      return events;
    } catch (e) {
      throw CacheException('Failed to get xp events: $e');
    }
  }

  Future<void> saveXpEvent(XpEventModel event) async {
    try {
      await _hiveDb.xpEvents.put(event.id, jsonEncode(event.toJson()));
    } catch (e) {
      throw CacheException('Failed to save xp event: $e');
    }
  }

  // ISLAND STATE
  Future<IslandStateModel?> getIsland(String islandId) async {
    try {
      final box = _hiveDb.island;
      final jsonString = box.get(islandId) as String?;
      if (jsonString == null) return null;
      return IslandStateModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException('Failed to get island: $e');
    }
  }

  Future<void> saveIsland(IslandStateModel island) async {
    try {
      await _hiveDb.island.put(island.id, jsonEncode(island.toJson()));
    } catch (e) {
      throw CacheException('Failed to save island: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _hiveDb.completions.clear();
      await _hiveDb.streaks.clear();
      await _hiveDb.xpEvents.clear();
      await _hiveDb.island.clear();
    } catch (e) {
      throw CacheException('Failed to clear all: $e');
    }
  }
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
  @override
  String toString() => 'CacheException: $message';
}
