import 'dart:convert';
import 'package:habbit_island/core/errors/exceptions.dart';
import 'package:habbit_island/data/models/premium_entitlement_model.dart';
import 'package:habbit_island/data/models/user_model.dart';

import 'hive_database.dart';

/// User Local Data Source
/// Handles local storage of user data using Hive
/// Reference: Technical Addendum §2.1 (Offline-First Architecture)

class UserLocalDataSource {
  final HiveDatabase _hiveDb;

  UserLocalDataSource(this._hiveDb);

  // User box uses single key 'current_user' since there's only one logged-in user
  static const String _currentUserKey = 'current_user';
  static const String _currentPremiumKey = 'current_premium';

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final box = _hiveDb.user;
      final jsonString = box.get(_currentUserKey) as String?;

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get current user: $e');
    }
  }

  /// Save user
  Future<void> saveUser(UserModel user) async {
    try {
      final box = _hiveDb.user;
      final jsonString = jsonEncode(user.toJson());
      await box.put(_currentUserKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save user: $e');
    }
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to update user: $e');
    }
  }

  /// Update user stats (XP, level, completions, etc.)
  Future<void> updateUserStats({
    int? totalXp,
    int? currentLevel,
    int? totalHabits,
    int? activeHabits,
    int? totalCompletions,
    int? longestStreak,
    int? currentGlobalStreak,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      final updatedUser = user.copyWith(
        totalXp: totalXp ?? user.totalXp,
        currentLevel: currentLevel ?? user.currentLevel,
        totalHabits: totalHabits ?? user.totalHabits,
        activeHabits: activeHabits ?? user.activeHabits,
        totalCompletions: totalCompletions ?? user.totalCompletions,
        longestStreak: longestStreak ?? user.longestStreak,
        currentGlobalStreak: currentGlobalStreak ?? user.currentGlobalStreak,
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to update user stats: $e');
    }
  }

  /// Add XP to user
  Future<void> addXp(int xpAmount) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      final newTotalXp = user.totalXp + xpAmount;
      final newLevel = (newTotalXp / 100).floor() + 1;

      final updatedUser = user.copyWith(
        totalXp: newTotalXp,
        currentLevel: newLevel,
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to add XP: $e');
    }
  }

  /// Unlock zone for user
  Future<void> unlockZone(String zoneId) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      if (user.unlockedZoneIds.contains(zoneId)) {
        return; // Already unlocked
      }

      final updatedZones = List<String>.from(user.unlockedZoneIds)..add(zoneId);

      final updatedUser = user.copyWith(
        unlockedZoneIds: updatedZones,
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to unlock zone: $e');
    }
  }

  /// Update premium status
  Future<void> updatePremiumStatus({
    required bool isPremium,
    PremiumTier? premiumTier,
    DateTime? premiumExpiresAt,
  }) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      final updatedUser = user.copyWith(
        isPremium: isPremium,
        premiumTier: premiumTier,
        premiumExpiresAt: premiumExpiresAt,
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to update premium status: $e');
    }
  }

  /// Update streak shields
  Future<void> updateStreakShields(int remaining) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      final updatedUser = user.copyWith(
        streakShieldsRemaining: remaining,
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to update streak shields: $e');
    }
  }

  /// Use streak shield
  Future<void> useStreakShield() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      if (user.streakShieldsRemaining <= 0) {
        throw ValidationException('No streak shields available');
      }

      await updateStreakShields(user.streakShieldsRemaining - 1);
    } catch (e) {
      throw CacheException('Failed to use streak shield: $e');
    }
  }

  /// Update vacation days
  Future<void> updateVacationDays(int remaining) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      final updatedUser = user.copyWith(
        vacationDaysRemaining: remaining,
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to update vacation days: $e');
    }
  }

  /// Use vacation day
  Future<void> useVacationDay() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      if (user.vacationDaysRemaining <= 0) {
        throw ValidationException('No vacation days available');
      }

      await updateVacationDays(user.vacationDaysRemaining - 1);
    } catch (e) {
      throw CacheException('Failed to use vacation day: $e');
    }
  }

  /// Update last login
  Future<void> updateLastLogin() async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        throw NotFoundException('Current user not found');
      }

      final updatedUser = user.copyWith(
        lastLoginAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to update last login: $e');
    }
  }

  /// Mark user as synced
  Future<void> markUserAsSynced() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return;

      final updatedUser = user.copyWith(lastSyncedAt: DateTime.now());

      await saveUser(updatedUser);
    } catch (e) {
      throw CacheException('Failed to mark user as synced: $e');
    }
  }

  /// Check if user needs sync
  Future<bool> userNeedsSync() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // User needs sync if:
      // 1. Never synced (lastSyncedAt is null)
      // 2. Updated after last sync
      if (user.lastSyncedAt == null) return true;
      return user.updatedAt.isAfter(user.lastSyncedAt!);
    } catch (e) {
      throw CacheException('Failed to check user sync status: $e');
    }
  }

  /// Delete current user
  Future<void> deleteUser() async {
    try {
      final box = _hiveDb.user;
      await box.delete(_currentUserKey);
    } catch (e) {
      throw CacheException('Failed to delete user: $e');
    }
  }

  /// Clear all user data
  Future<void> clearAll() async {
    try {
      await _hiveDb.user.clear();
      await _hiveDb.premium.clear();
    } catch (e) {
      throw CacheException('Failed to clear user data: $e');
    }
  }

  // ============================================================================
  // PREMIUM ENTITLEMENT OPERATIONS
  // ============================================================================

  /// Get current premium entitlement
  Future<PremiumEntitlementModel?> getCurrentPremium() async {
    try {
      final box = _hiveDb.premium;
      final jsonString = box.get(_currentPremiumKey) as String?;

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PremiumEntitlementModel.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get premium entitlement: $e');
    }
  }

  /// Save premium entitlement
  Future<void> savePremium(PremiumEntitlementModel premium) async {
    try {
      final box = _hiveDb.premium;
      final jsonString = jsonEncode(premium.toJson());
      await box.put(_currentPremiumKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save premium entitlement: $e');
    }
  }

  /// Update premium entitlement
  Future<void> updatePremium(PremiumEntitlementModel premium) async {
    try {
      final updatedPremium = premium.copyWith(updatedAt: DateTime.now());
      await savePremium(updatedPremium);
    } catch (e) {
      throw CacheException('Failed to update premium entitlement: $e');
    }
  }

  /// Use streak shield from premium
  Future<void> usePremiumStreakShield() async {
    try {
      final premium = await getCurrentPremium();
      if (premium == null) {
        throw NotFoundException('Premium entitlement not found');
      }

      if (!premium.hasStreakShields) {
        throw ValidationException('No streak shields available');
      }

      final updatedPremium = premium.copyWith(
        streakShieldsUsed: premium.streakShieldsUsed + 1,
        updatedAt: DateTime.now(),
      );

      await savePremium(updatedPremium);

      // Also update user's streak shields
      await updateStreakShields(updatedPremium.streakShieldsRemaining);
    } catch (e) {
      throw CacheException('Failed to use premium streak shield: $e');
    }
  }

  /// Use vacation day from premium
  Future<void> usePremiumVacationDay() async {
    try {
      final premium = await getCurrentPremium();
      if (premium == null) {
        throw NotFoundException('Premium entitlement not found');
      }

      if (!premium.hasVacationDays) {
        throw ValidationException('No vacation days available');
      }

      final updatedPremium = premium.copyWith(
        vacationDaysUsed: premium.vacationDaysUsed + 1,
        updatedAt: DateTime.now(),
      );

      await savePremium(updatedPremium);

      // Also update user's vacation days
      await updateVacationDays(updatedPremium.vacationDaysRemaining);
    } catch (e) {
      throw CacheException('Failed to use premium vacation day: $e');
    }
  }

  /// Delete premium entitlement
  Future<void> deletePremium() async {
    try {
      final box = _hiveDb.premium;
      await box.delete(_currentPremiumKey);
    } catch (e) {
      throw CacheException('Failed to delete premium entitlement: $e');
    }
  }
}
