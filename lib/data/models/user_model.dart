import 'package:equatable/equatable.dart';

/// User Model (Data Layer)
/// Reference: Product Documentation v1.0 §6 (Premium System)
///
/// Represents a user with profile, premium status, and aggregate stats.

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isPremium;
  final PremiumTier? premiumTier;
  final DateTime? premiumExpiresAt;
  final int totalXp;
  final int currentLevel;
  final int totalHabits;
  final int activeHabits;
  final int totalCompletions;
  final int longestStreak;
  final int currentGlobalStreak; // Streak for completing all daily habits
  final String currentIslandId;
  final List<String> unlockedZoneIds;
  final int streakShieldsRemaining;
  final int vacationDaysRemaining;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isPremium = false,
    this.premiumTier,
    this.premiumExpiresAt,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.totalHabits = 0,
    this.activeHabits = 0,
    this.totalCompletions = 0,
    this.longestStreak = 0,
    this.currentGlobalStreak = 0,
    required this.currentIslandId,
    this.unlockedZoneIds = const [],
    this.streakShieldsRemaining = 0,
    this.vacationDaysRemaining = 0,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    isPremium,
    premiumTier,
    premiumExpiresAt,
    totalXp,
    currentLevel,
    totalHabits,
    activeHabits,
    totalCompletions,
    longestStreak,
    currentGlobalStreak,
    currentIslandId,
    unlockedZoneIds,
    streakShieldsRemaining,
    vacationDaysRemaining,
    lastLoginAt,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      premiumTier: json['premium_tier'] != null
          ? PremiumTier.values.firstWhere(
              (e) => e.name == json['premium_tier'],
              orElse: () => PremiumTier.free,
            )
          : null,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'] as String)
          : null,
      totalXp: json['total_xp'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      totalHabits: json['total_habits'] as int? ?? 0,
      activeHabits: json['active_habits'] as int? ?? 0,
      totalCompletions: json['total_completions'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      currentGlobalStreak: json['current_global_streak'] as int? ?? 0,
      currentIslandId: json['current_island_id'] as String,
      unlockedZoneIds: json['unlocked_zone_ids'] != null
          ? List<String>.from(json['unlocked_zone_ids'] as List)
          : const [],
      streakShieldsRemaining: json['streak_shields_remaining'] as int? ?? 0,
      vacationDaysRemaining: json['vacation_days_remaining'] as int? ?? 0,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'is_premium': isPremium,
      'premium_tier': premiumTier?.name,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'total_xp': totalXp,
      'current_level': currentLevel,
      'total_habits': totalHabits,
      'active_habits': activeHabits,
      'total_completions': totalCompletions,
      'longest_streak': longestStreak,
      'current_global_streak': currentGlobalStreak,
      'current_island_id': currentIslandId,
      'unlocked_zone_ids': unlockedZoneIds,
      'streak_shields_remaining': streakShieldsRemaining,
      'vacation_days_remaining': vacationDaysRemaining,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isPremium,
    PremiumTier? premiumTier,
    DateTime? premiumExpiresAt,
    int? totalXp,
    int? currentLevel,
    int? totalHabits,
    int? activeHabits,
    int? totalCompletions,
    int? longestStreak,
    int? currentGlobalStreak,
    String? currentIslandId,
    List<String>? unlockedZoneIds,
    int? streakShieldsRemaining,
    int? vacationDaysRemaining,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      premiumTier: premiumTier ?? this.premiumTier,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      totalHabits: totalHabits ?? this.totalHabits,
      activeHabits: activeHabits ?? this.activeHabits,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      longestStreak: longestStreak ?? this.longestStreak,
      currentGlobalStreak: currentGlobalStreak ?? this.currentGlobalStreak,
      currentIslandId: currentIslandId ?? this.currentIslandId,
      unlockedZoneIds: unlockedZoneIds ?? this.unlockedZoneIds,
      streakShieldsRemaining:
          streakShieldsRemaining ?? this.streakShieldsRemaining,
      vacationDaysRemaining:
          vacationDaysRemaining ?? this.vacationDaysRemaining,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if premium is active
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumTier == PremiumTier.lifetime) return true;
    if (premiumExpiresAt == null) return false;
    return DateTime.now().isBefore(premiumExpiresAt!);
  }

  /// Days until premium expires
  int? get daysUntilPremiumExpires {
    if (!isPremiumActive) return null;
    if (premiumTier == PremiumTier.lifetime) return null;
    if (premiumExpiresAt == null) return null;
    return premiumExpiresAt!.difference(DateTime.now()).inDays;
  }

  /// Check if has unlimited habits
  bool get hasUnlimitedHabits => isPremiumActive;

  /// Maximum habits allowed (7 for free, 999 for premium)
  /// Reference: Product Documentation §3.1
  int get maxHabitsAllowed => isPremiumActive ? 999 : 7;

  /// Check if can create more habits
  bool get canCreateMoreHabits => activeHabits < maxHabitsAllowed;

  /// Check if has streak shields available
  bool get hasStreakShields => streakShieldsRemaining > 0;

  /// Check if has vacation days available
  bool get hasVacationDays => vacationDaysRemaining > 0;

  /// Get XP required for next level (100 XP per level)
  int get xpRequiredForNextLevel => currentLevel * 100;

  /// Get XP progress to next level (0.0 to 1.0)
  double get xpProgressToNextLevel {
    final xpForCurrentLevel = (currentLevel - 1) * 100;
    final xpInCurrentLevel = totalXp - xpForCurrentLevel;
    return xpInCurrentLevel / 100.0;
  }

  /// Check if zone is unlocked
  bool isZoneUnlocked(String zoneId) => unlockedZoneIds.contains(zoneId);

  /// Get user's initials for avatar
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email[0].toUpperCase();
    }
    final parts = displayName!.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Check if first day user
  bool get isNewUser {
    final now = DateTime.now();
    return now.difference(createdAt).inDays == 0;
  }
}

// ============================================================================
// ENUMS
// ============================================================================

/// Premium tier (Product Documentation §6.2)
enum PremiumTier {
  free, // Free tier - 7 habits max
  monthly, // $4.99/month
  annual, // $39.99/year (17% savings)
  lifetime, // $49.99 one-time (launch special)
}

extension PremiumTierExtension on PremiumTier {
  String get displayName {
    switch (this) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.monthly:
        return 'Premium Monthly';
      case PremiumTier.annual:
        return 'Premium Annual';
      case PremiumTier.lifetime:
        return 'Premium Lifetime';
    }
  }

  double? get price {
    switch (this) {
      case PremiumTier.free:
        return null;
      case PremiumTier.monthly:
        return 4.99;
      case PremiumTier.annual:
        return 39.99;
      case PremiumTier.lifetime:
        return 49.99;
    }
  }

  String? get priceFormatted {
    final p = price;
    if (p == null) return null;
    return '\$${p.toStringAsFixed(2)}';
  }

  String get billingPeriod {
    switch (this) {
      case PremiumTier.free:
        return '';
      case PremiumTier.monthly:
        return 'per month';
      case PremiumTier.annual:
        return 'per year';
      case PremiumTier.lifetime:
        return 'one-time';
    }
  }
}
