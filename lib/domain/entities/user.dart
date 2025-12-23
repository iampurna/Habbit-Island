import 'package:equatable/equatable.dart';

/// User Entity
/// Domain representation of an application user

enum PremiumTier { free, monthly, annual, lifetime }

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isPremium;
  final PremiumTier premiumTier;
  final int totalXp;
  final int currentLevel;
  final int totalHabits;
  final int activeHabits;
  final int totalCompletions;
  final int longestStreak;
  final int currentGlobalStreak;
  final String? currentIslandId;
  final List<String> unlockedZoneIds;
  final int streakShieldsRemaining;
  final int vacationDaysRemaining;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.isPremium,
    required this.premiumTier,
    required this.totalXp,
    required this.currentLevel,
    required this.totalHabits,
    required this.activeHabits,
    required this.totalCompletions,
    required this.longestStreak,
    required this.currentGlobalStreak,
    this.currentIslandId,
    required this.unlockedZoneIds,
    required this.streakShieldsRemaining,
    required this.vacationDaysRemaining,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    isPremium,
    premiumTier,
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
  ];

  // ============================================================================
  // BUSINESS LOGIC
  // ============================================================================

  /// Calculate XP required for next level (100 XP per level)
  int get xpRequiredForNextLevel {
    return (currentLevel + 1) * 100;
  }

  /// Calculate XP progress to next level (0.0 - 1.0)
  double get xpProgressToNextLevel {
    final xpInCurrentLevel = totalXp - (currentLevel * 100);
    return xpInCurrentLevel / 100;
  }

  /// Calculate XP remaining to next level
  int get xpRemainingForNextLevel {
    final xpInCurrentLevel = totalXp - (currentLevel * 100);
    return 100 - xpInCurrentLevel;
  }

  /// Check if can create more habits (7 for free, unlimited for premium)
  bool get canCreateHabit {
    if (isPremium) return true;
    return totalHabits < 7;
  }

  /// Get remaining habit slots for free users
  int get remainingHabitSlots {
    if (isPremium) return 999;
    return (7 - totalHabits).clamp(0, 7);
  }

  /// Check if has streak shields available
  bool get hasStreakShields {
    return streakShieldsRemaining > 0;
  }

  /// Check if has vacation days available
  bool get hasVacationDays {
    return vacationDaysRemaining > 0;
  }

  /// Check if logged in today
  bool get loggedInToday {
    if (lastLoginAt == null) return false;

    final now = DateTime.now();
    final lastLogin = lastLoginAt!;

    return now.year == lastLogin.year &&
        now.month == lastLogin.month &&
        now.day == lastLogin.day;
  }

  /// Get days since last login
  int get daysSinceLastLogin {
    if (lastLoginAt == null) return 0;
    return DateTime.now().difference(lastLoginAt!).inDays;
  }

  /// Check if user is new (created within last 7 days)
  bool get isNewUser {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation < 7;
  }

  /// Check if user is active (has habits and completions)
  bool get isActiveUser {
    return activeHabits > 0 && totalCompletions > 0;
  }

  /// Check if user is dormant (no login for 30+ days)
  bool get isDormant {
    return daysSinceLastLogin >= 30;
  }

  /// Calculate user engagement level (0-5)
  int get engagementLevel {
    int level = 0;

    // Has active habits
    if (activeHabits > 0) level++;

    // Regular completions (at least 10)
    if (totalCompletions >= 10) level++;

    // Has a streak going
    if (currentGlobalStreak > 0) level++;

    // Long streak (7+ days)
    if (currentGlobalStreak >= 7) level++;

    // Very engaged (30+ completions)
    if (totalCompletions >= 30) level++;

    return level;
  }

  /// Get user rank based on level
  String get rank {
    if (currentLevel < 5) return 'Beginner';
    if (currentLevel < 10) return 'Explorer';
    if (currentLevel < 20) return 'Adventurer';
    if (currentLevel < 50) return 'Expert';
    if (currentLevel < 100) return 'Master';
    return 'Legend';
  }

  /// Check if has unlocked specific zone
  bool hasUnlockedZone(String zoneId) {
    return unlockedZoneIds.contains(zoneId);
  }

  /// Get completion rate (active habits vs total habits)
  double get habitActiveRate {
    if (totalHabits == 0) return 0.0;
    return activeHabits / totalHabits;
  }

  /// Calculate average completions per habit
  double get averageCompletionsPerHabit {
    if (totalHabits == 0) return 0.0;
    return totalCompletions / totalHabits;
  }

  // ============================================================================
  // PREMIUM FEATURES
  // ============================================================================

  /// Check if premium is active
  bool get isPremiumActive {
    return isPremium && premiumTier != PremiumTier.free;
  }

  /// Get premium tier name
  String get premiumTierName {
    switch (premiumTier) {
      case PremiumTier.free:
        return 'Free';
      case PremiumTier.monthly:
        return 'Monthly';
      case PremiumTier.annual:
        return 'Annual';
      case PremiumTier.lifetime:
        return 'Lifetime';
    }
  }

  /// Check if can use streak shield
  bool get canUseStreakShield {
    return isPremium && streakShieldsRemaining > 0;
  }

  /// Check if can use vacation day
  bool get canUseVacationDay {
    return isPremium && vacationDaysRemaining > 0;
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Validate user data
  bool isValid() {
    // Email must be valid
    if (!_isValidEmail(email)) return false;

    // Display name must not be empty
    if (displayName.trim().isEmpty) return false;

    // Counts must be non-negative
    if (totalXp < 0 ||
        currentLevel < 0 ||
        totalHabits < 0 ||
        activeHabits < 0 ||
        totalCompletions < 0) {
      return false;
    }

    // Active habits cannot exceed total habits
    if (activeHabits > totalHabits) return false;

    // Streak shields and vacation days must be non-negative
    if (streakShieldsRemaining < 0 || vacationDaysRemaining < 0) {
      return false;
    }

    // XP and level must be consistent (level = totalXp / 100)
    final calculatedLevel = (totalXp / 100).floor() + 1;
    if (currentLevel != calculatedLevel) return false;

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isPremium,
    PremiumTier? premiumTier,
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
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      premiumTier: premiumTier ?? this.premiumTier,
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
    );
  }
}
