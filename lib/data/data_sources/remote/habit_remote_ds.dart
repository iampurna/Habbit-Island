import 'package:habbit_island/core/errors/exceptions.dart';
import 'package:habbit_island/data/models/habit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Habit Remote Data Source - Supabase operations
class HabitRemoteDataSource {
  final SupabaseClientManager _supabaseManager;

  HabitRemoteDataSource(this._supabaseManager);

  SupabaseClient get _client => _supabaseManager.client;

  // CREATE
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final response = await _client
          .from('habits')
          .insert(habit.toJson())
          .select()
          .single();

      return HabitModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create habit: $e');
    }
  }

  // READ
  Future<List<HabitModel>> getHabits(String userId) async {
    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HabitModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get habits: $e');
    }
  }

  Future<HabitModel?> getHabit(String habitId) async {
    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('id', habitId)
          .maybeSingle();

      return response != null ? HabitModel.fromJson(response) : null;
    } catch (e) {
      throw ServerException('Failed to get habit: $e');
    }
  }

  Future<List<HabitModel>> getActiveHabits(String userId) async {
    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => HabitModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get active habits: $e');
    }
  }

  Future<List<HabitModel>> getHabitsByZone(String userId, String zoneId) async {
    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .eq('zone_id', zoneId)
          .eq('is_active', true);

      return (response as List)
          .map((json) => HabitModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get habits by zone: $e');
    }
  }

  // UPDATE
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      final response = await _client
          .from('habits')
          .update(habit.toJson())
          .eq('id', habit.id)
          .select()
          .single();

      return HabitModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update habit: $e');
    }
  }

  Future<void> updateHabitStreak(
    String habitId,
    int currentStreak,
    int longestStreak,
    DateTime? lastCompletedAt,
  ) async {
    try {
      await _client
          .from('habits')
          .update({
            'current_streak': currentStreak,
            'longest_streak': longestStreak,
            'last_completed_at': lastCompletedAt?.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', habitId);
    } catch (e) {
      throw ServerException('Failed to update habit streak: $e');
    }
  }

  Future<void> incrementCompletionCount(String habitId) async {
    try {
      await _client.rpc(
        'increment_habit_completions',
        params: {'habit_id': habitId},
      );
    } catch (e) {
      throw ServerException('Failed to increment completion count: $e');
    }
  }

  // DELETE
  Future<void> deleteHabit(String habitId) async {
    try {
      await _client.from('habits').delete().eq('id', habitId);
    } catch (e) {
      throw ServerException('Failed to delete habit: $e');
    }
  }

  Future<void> softDeleteHabit(String habitId) async {
    try {
      await _client
          .from('habits')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', habitId);
    } catch (e) {
      throw ServerException('Failed to soft delete habit: $e');
    }
  }

  // BATCH
  Future<void> batchCreateHabits(List<HabitModel> habits) async {
    try {
      await _client
          .from('habits')
          .insert(habits.map((h) => h.toJson()).toList());
    } catch (e) {
      throw ServerException('Failed to batch create habits: $e');
    }
  }

  Future<void> batchUpdateHabits(List<HabitModel> habits) async {
    try {
      await _client
          .from('habits')
          .upsert(habits.map((h) => h.toJson()).toList());
    } catch (e) {
      throw ServerException('Failed to batch update habits: $e');
    }
  }

  // VALIDATION
  Future<bool> habitNameExists(
    String userId,
    String name, {
    String? excludeId,
  }) async {
    try {
      var query = _client
          .from('habits')
          .select('id')
          .eq('user_id', userId)
          .ilike('name', name);

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final response = await query.maybeSingle();
      return response != null;
    } catch (e) {
      throw ServerException('Failed to check habit name: $e');
    }
  }

  Future<PostgrestResponse<PostgrestList>> countHabits(
    String userId, {
    bool activeOnly = false,
  }) async {
    try {
      var query = _client.from('habits').select('*').eq('user_id', userId);

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      return await query.count(CountOption.exact);
    } catch (e) {
      throw ServerException('Failed to count habits: $e');
    }
  }
}
