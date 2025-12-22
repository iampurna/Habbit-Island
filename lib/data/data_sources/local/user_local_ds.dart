import 'package:habbit_island/data/data_sources/remote/supabase_client.dart';
import 'package:habbit_island/data/models/premium_entitlement_model.dart';
import 'package:habbit_island/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User & Premium Remote Data Source
class UserRemoteDataSource {
  final SupabaseClientManager _supabaseManager;

  UserRemoteDataSource(this._supabaseManager);

  SupabaseClient get _client => _supabaseManager.client;

  // USER OPERATIONS
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _client
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response != null ? UserModel.fromJson(response) : null;
    } catch (e) {
      throw ServerException('Failed to get user: $e');
    }
  }

  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update user: $e');
    }
  }

  Future<void> addXp(String userId, int xpAmount) async {
    try {
      await _client.rpc(
        'add_user_xp',
        params: {'user_id': userId, 'xp_amount': xpAmount},
      );
    } catch (e) {
      throw ServerException('Failed to add XP: $e');
    }
  }

  Future<void> unlockZone(String userId, String zoneId) async {
    try {
      final user = await getUser(userId);
      if (user == null) throw NotFoundException('User not found');

      if (!user.unlockedZoneIds.contains(zoneId)) {
        final updatedZones = [...user.unlockedZoneIds, zoneId];
        await _client
            .from('users')
            .update({
              'unlocked_zone_ids': updatedZones,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      }
    } catch (e) {
      throw ServerException('Failed to unlock zone: $e');
    }
  }

  Future<void> updateLastLogin(String userId) async {
    try {
      await _client
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      throw ServerException('Failed to update last login: $e');
    }
  }

  // PREMIUM OPERATIONS
  Future<PremiumEntitlementModel> createPremium(
    PremiumEntitlementModel premium,
  ) async {
    try {
      final response = await _client
          .from('premium_entitlements')
          .insert(premium.toJson())
          .select()
          .single();
      return PremiumEntitlementModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create premium: $e');
    }
  }

  Future<PremiumEntitlementModel?> getPremium(String userId) async {
    try {
      final response = await _client
          .from('premium_entitlements')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();
      return response != null
          ? PremiumEntitlementModel.fromJson(response)
          : null;
    } catch (e) {
      throw ServerException('Failed to get premium: $e');
    }
  }

  Future<void> updatePremium(PremiumEntitlementModel premium) async {
    try {
      await _client
          .from('premium_entitlements')
          .update(premium.toJson())
          .eq('id', premium.id);
    } catch (e) {
      throw ServerException('Failed to update premium: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _client.from('users').delete().eq('id', userId);
    } catch (e) {
      throw ServerException('Failed to delete user: $e');
    }
  }
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  @override
  String toString() => 'ServerException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}
