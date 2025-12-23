import 'package:habbit_island/core/errors/exceptions.dart';
import 'package:habbit_island/data/models/habit_completion_model.dart';
import 'package:habbit_island/data/models/habit_model.dart';
import 'package:habbit_island/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

/// Sync Remote Data Source - Handles batch sync operations
class SyncRemoteDataSource {
  final SupabaseClientManager _supabaseManager;

  SyncRemoteDataSource(this._supabaseManager);

  SupabaseClient get _client => _supabaseManager.client;

  // PULL SYNC - Get all user data from server
  Future<SyncPullResult> pullUserData(
    String userId,
    DateTime? lastSyncAt,
  ) async {
    try {
      // Get all habits
      var habitsQuery = _client.from('habits').select().eq('user_id', userId);

      if (lastSyncAt != null) {
        habitsQuery = habitsQuery.gt(
          'updated_at',
          lastSyncAt.toIso8601String(),
        );
      }

      final habitsResponse = await habitsQuery;
      final habits = (habitsResponse as List)
          .map((json) => HabitModel.fromJson(json))
          .toList();

      // Get completions (last 90 days)
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      var completionsQuery = _client
          .from('habit_completions')
          .select()
          .eq('user_id', userId)
          .gte('logical_date', cutoffDate.toIso8601String());

      if (lastSyncAt != null) {
        completionsQuery = completionsQuery.gt(
          'created_at',
          lastSyncAt.toIso8601String(),
        );
      }

      final completionsResponse = await completionsQuery;
      final completions = (completionsResponse as List)
          .map((json) => HabitCompletionModel.fromJson(json))
          .toList();

      // Get user data
      final userResponse = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      final user = UserModel.fromJson(userResponse);

      return SyncPullResult(
        habits: habits,
        completions: completions,
        user: user,
        syncedAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException('Failed to pull user data: $e');
    }
  }

  // PUSH SYNC - Send local changes to server
  Future<void> pushHabits(List<HabitModel> habits) async {
    try {
      if (habits.isEmpty) return;

      await _client
          .from('habits')
          .upsert(habits.map((h) => h.toJson()).toList());
    } catch (e) {
      throw ServerException('Failed to push habits: $e');
    }
  }

  Future<void> pushCompletions(List<HabitCompletionModel> completions) async {
    try {
      if (completions.isEmpty) return;

      await _client
          .from('habit_completions')
          .upsert(completions.map((c) => c.toJson()).toList());
    } catch (e) {
      throw ServerException('Failed to push completions: $e');
    }
  }

  Future<void> pushUser(UserModel user) async {
    try {
      await _client.from('users').upsert(user.toJson());
    } catch (e) {
      throw ServerException('Failed to push user: $e');
    }
  }

  // CHECK SYNC STATUS
  Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('last_synced_at')
          .eq('id', userId)
          .single();

      final lastSyncedAt = response['last_synced_at'] as String?;
      return lastSyncedAt != null ? DateTime.parse(lastSyncedAt) : null;
    } catch (e) {
      throw ServerException('Failed to get last sync time: $e');
    }
  }

  Future<void> updateLastSyncTime(String userId) async {
    try {
      await _client
          .from('users')
          .update({'last_synced_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      throw ServerException('Failed to update last sync time: $e');
    }
  }

  // CONFLICT RESOLUTION
  Future<HabitModel> resolveHabitConflict(
    HabitModel local,
    HabitModel remote,
  ) async {
    // Last-write-wins strategy
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      await pushHabits([local]);
      return local;
    } else {
      return remote;
    }
  }
}

class SyncPullResult {
  final List<HabitModel> habits;
  final List<HabitCompletionModel> completions;
  final UserModel user;
  final DateTime syncedAt;

  const SyncPullResult({
    required this.habits,
    required this.completions,
    required this.user,
    required this.syncedAt,
  });
}
