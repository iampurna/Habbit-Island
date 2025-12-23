import 'package:habbit_island/core/errors/exceptions.dart';
import 'package:habbit_island/data/models/habit_completion_model.dart';
import 'package:habbit_island/data/models/habit_streak_model.dart';
import 'package:habbit_island/data/models/island_state_model.dart';
import 'package:habbit_island/data/models/xp_event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Completions, Streaks, XP & Island Remote Data Source
class CompletionsRemoteDataSource {
  final SupabaseClientManager _supabaseManager;

  CompletionsRemoteDataSource(this._supabaseManager);

  SupabaseClient get _client => _supabaseManager.client;

  // COMPLETIONS
  Future<HabitCompletionModel> createCompletion(
    HabitCompletionModel completion,
  ) async {
    try {
      final response = await _client
          .from('habit_completions')
          .insert(completion.toJson())
          .select()
          .single();
      return HabitCompletionModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create completion: $e');
    }
  }

  Future<List<HabitCompletionModel>> getCompletions(String habitId) async {
    try {
      final response = await _client
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .order('completed_at', ascending: false);

      return (response as List)
          .map((json) => HabitCompletionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get completions: $e');
    }
  }

  Future<List<HabitCompletionModel>> getCompletionsByDateRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final response = await _client
          .from('habit_completions')
          .select()
          .eq('habit_id', habitId)
          .gte('logical_date', start.toIso8601String())
          .lte('logical_date', end.toIso8601String())
          .order('logical_date', ascending: false);

      return (response as List)
          .map((json) => HabitCompletionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get completions by date range: $e');
    }
  }

  Future<void> deleteCompletion(String completionId) async {
    try {
      await _client.from('habit_completions').delete().eq('id', completionId);
    } catch (e) {
      throw ServerException('Failed to delete completion: $e');
    }
  }

  // STREAKS
  Future<HabitStreakModel> createStreak(HabitStreakModel streak) async {
    try {
      final response = await _client
          .from('habit_streaks')
          .insert(streak.toJson())
          .select()
          .single();
      return HabitStreakModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create streak: $e');
    }
  }

  Future<HabitStreakModel?> getStreak(String habitId) async {
    try {
      final response = await _client
          .from('habit_streaks')
          .select()
          .eq('habit_id', habitId)
          .maybeSingle();

      return response != null ? HabitStreakModel.fromJson(response) : null;
    } catch (e) {
      throw ServerException('Failed to get streak: $e');
    }
  }

  Future<void> updateStreak(HabitStreakModel streak) async {
    try {
      await _client.from('habit_streaks').upsert(streak.toJson());
    } catch (e) {
      throw ServerException('Failed to update streak: $e');
    }
  }

  // XP EVENTS
  Future<XpEventModel> createXpEvent(XpEventModel event) async {
    try {
      final response = await _client
          .from('xp_events')
          .insert(event.toJson())
          .select()
          .single();
      return XpEventModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create xp event: $e');
    }
  }

  Future<List<XpEventModel>> getXpEvents(String userId, {int? limit}) async {
    try {
      var query = _client
          .from('xp_events')
          .select()
          .eq('user_id', userId)
          .order('earned_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => XpEventModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get xp events: $e');
    }
  }

  Future<int> getTotalXp(String userId) async {
    try {
      final response = await _client
          .from('xp_events')
          .select('xp_amount')
          .eq('user_id', userId);

      int total = 0;
      for (final event in response as List) {
        total += event['xp_amount'] as int;
      }

      return total;
    } catch (e) {
      throw ServerException('Failed to get total xp: $e');
    }
  }

  // ISLAND STATE
  Future<IslandStateModel> createIsland(IslandStateModel island) async {
    try {
      final response = await _client
          .from('island_states')
          .insert(island.toJson())
          .select()
          .single();
      return IslandStateModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create island: $e');
    }
  }

  Future<IslandStateModel?> getIsland(String islandId) async {
    try {
      final response = await _client
          .from('island_states')
          .select()
          .eq('id', islandId)
          .maybeSingle();

      return response != null ? IslandStateModel.fromJson(response) : null;
    } catch (e) {
      throw ServerException('Failed to get island: $e');
    }
  }

  Future<List<IslandStateModel>> getUserIslands(String userId) async {
    try {
      final response = await _client
          .from('island_states')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => IslandStateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user islands: $e');
    }
  }

  Future<void> updateIsland(IslandStateModel island) async {
    try {
      await _client
          .from('island_states')
          .update(island.toJson())
          .eq('id', island.id);
    } catch (e) {
      throw ServerException('Failed to update island: $e');
    }
  }
}
