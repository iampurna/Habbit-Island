import '../constants/app_constants.dart';

/// Habit Island XP Calculator
/// Reference: Product Documentation v1.0 §3.2
///
/// Calculates experience points based on exact values from documentation.
/// NO multiplier system - fixed XP amounts per action.
class XpCalculator {
  XpCalculator._();

  // ============================================================================
  // XP EARNING (Product Documentation §3.2)
  // ============================================================================

  /// Calculate XP for a single habit completion
  /// Always returns fixed amount per documentation
  static int calculateHabitCompletionXp() {
    return AppConstants.xpPerHabitCompletion; // 10 XP
  }

  /// Calculate bonus XP for completing ALL daily habits
  static int calculateAllDailyCompleteBonus() {
    return AppConstants.xpBonusAllDailyComplete; // 50 XP
  }

  /// Calculate milestone bonus XP for streaks
  /// Returns XP if milestone reached, null otherwise
  static int? calculateStreakMilestoneXp(int streakDays) {
    return AppConstants.getStreakMilestoneXp(streakDays);
    // Returns 100 for 7-day, 500 for 30-day, null otherwise
  }

  /// Calculate daily login bonus XP
  static int calculateDailyLoginXp() {
    return AppConstants.xpDailyLogin; // 5 XP
  }

  /// Calculate XP for watching rewarded ad
  static int calculateRewardedAdXp() {
    return AppConstants.xpRewardedAd; // 50 XP
  }

  // ============================================================================
  // TOTAL XP CALCULATION
  // ============================================================================

  /// Calculate total XP for a day's activities
  ///
  /// Example:
  /// - 3 habits completed: 3 × 10 = 30 XP
  /// - All 3 daily habits done: +50 bonus = 80 XP
  /// - 7-day streak milestone: +100 bonus = 180 XP
  /// - Daily login: +5 = 185 XP
  static int calculateDailyTotalXp({
    required int habitsCompleted,
    required int totalDailyHabits,
    required int currentStreak,
    required bool isFirstLoginToday,
  }) {
    int totalXp = 0;

    // Base XP from habit completions
    totalXp += habitsCompleted * calculateHabitCompletionXp();

    // All daily complete bonus
    if (habitsCompleted == totalDailyHabits && totalDailyHabits > 0) {
      totalXp += calculateAllDailyCompleteBonus();
    }

    // Streak milestone bonus (only on the milestone day)
    final milestoneXp = calculateStreakMilestoneXp(currentStreak);
    if (milestoneXp != null) {
      totalXp += milestoneXp;
    }

    // Daily login bonus
    if (isFirstLoginToday) {
      totalXp += calculateDailyLoginXp();
    }

    return totalXp;
  }

  // ============================================================================
  // XP VALIDATION
  // ============================================================================

  /// Check if XP amount is valid (positive, within reasonable bounds)
  static bool isValidXpAmount(int xp) {
    return xp >= 0 && xp <= 10000; // Sanity check
  }

  // ============================================================================
  // ZONE UNLOCKING
  // ============================================================================

  /// Check if user has enough XP to unlock a specific zone
  static bool canUnlockZone(int currentXp, String zoneName) {
    final requiredXp = AppConstants.getMaxHabitsForZone(zoneName);
    return currentXp >= requiredXp;
  }

  /// Get next zone XP requirement
  static int? getNextZoneXpRequirement(int currentXp) {
    if (currentXp < AppConstants.xpForestGrove) {
      return AppConstants.xpForestGrove; // 101 XP
    }
    if (currentXp < AppConstants.xpMountainRidge) {
      return AppConstants.xpMountainRidge; // 301 XP
    }
    return null; // All zones unlocked
  }

  /// Calculate XP progress to next zone (0.0 to 1.0)
  static double calculateZoneProgress(int currentXp) {
    if (currentXp < AppConstants.xpForestGrove) {
      // Progress to Forest Grove (0-101 XP)
      return currentXp / AppConstants.xpForestGrove;
    }
    if (currentXp < AppConstants.xpMountainRidge) {
      // Progress to Mountain Ridge (101-301 XP)
      final rangeStart = AppConstants.xpForestGrove;
      final rangeEnd = AppConstants.xpMountainRidge;
      return (currentXp - rangeStart) / (rangeEnd - rangeStart);
    }
    // All zones unlocked
    return 1.0;
  }

  // ============================================================================
  // XP STATISTICS
  // ============================================================================

  /// Calculate average XP per day over a period
  static double calculateAverageXpPerDay(int totalXp, int days) {
    if (days <= 0) return 0;
    return totalXp / days;
  }

  /// Estimate XP needed for N more zones
  static int estimateXpForZones(int currentXp, int zonesNeeded) {
    if (zonesNeeded <= 0) return 0;

    int xpNeeded = 0;

    // Forest Grove
    if (currentXp < AppConstants.xpForestGrove) {
      xpNeeded = AppConstants.xpForestGrove - currentXp;
      zonesNeeded--;
    }

    // Mountain Ridge
    if (zonesNeeded > 0 && currentXp < AppConstants.xpMountainRidge) {
      final remaining =
          AppConstants.xpMountainRidge -
          (currentXp > AppConstants.xpForestGrove
              ? currentXp
              : AppConstants.xpForestGrove);
      xpNeeded += remaining;
    }

    return xpNeeded;
  }

  // ============================================================================
  // MILESTONE DETECTION
  // ============================================================================

  /// Check if current XP crosses a milestone boundary
  static bool crossesMilestone(int previousXp, int newXp) {
    return (previousXp < AppConstants.xpForestGrove &&
            newXp >= AppConstants.xpForestGrove) ||
        (previousXp < AppConstants.xpMountainRidge &&
            newXp >= AppConstants.xpMountainRidge);
  }

  /// Get milestone type if crossed
  static String? getMilestoneCrossed(int previousXp, int newXp) {
    if (previousXp < AppConstants.xpForestGrove &&
        newXp >= AppConstants.xpForestGrove) {
      return 'forest_grove';
    }
    if (previousXp < AppConstants.xpMountainRidge &&
        newXp >= AppConstants.xpMountainRidge) {
      return 'mountain_ridge';
    }
    return null;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Format XP with thousands separator
  static String formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }

  /// Calculate XP for multiple habit completions
  static int calculateBatchXp(int habitCount) {
    return habitCount * calculateHabitCompletionXp();
  }
}
