import 'date_utils.dart';

/// Habit Island Streak Calculator
/// CRITICAL: Streaks are NEVER synced directly—always recalculated from completions.
/// This implements the reconstruction algorithm from the Technical Addendum.
class StreakCalculator {
  StreakCalculator._();

  // ============================================================================
  // STREAK RECONSTRUCTION
  // ============================================================================

  /// Calculate current streak from completion dates
  /// Returns streak count (0 if broken)
  ///
  /// Algorithm per Technical Addendum §3.3:
  /// 1. Sort completions descending (newest first)
  /// 2. Start with today or yesterday as expected date
  /// 3. Walk backwards, incrementing streak for each matching date
  /// 4. Break on first gap
  static int calculateStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    // Sort dates in descending order (newest first)
    final sortedDates = List<DateTime>.from(completionDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime expectedDate = AppDateUtils.startOfDay(AppDateUtils.now);

    // Check if streak is already broken (no completion today or yesterday)
    final lastCompletion = AppDateUtils.startOfDay(sortedDates.first);
    if (!AppDateUtils.isSameDay(lastCompletion, expectedDate) &&
        !AppDateUtils.isSameDay(lastCompletion, AppDateUtils.yesterday)) {
      return 0; // Streak broken
    }

    // If last completion was yesterday, start from yesterday
    if (AppDateUtils.isSameDay(lastCompletion, AppDateUtils.yesterday)) {
      expectedDate = AppDateUtils.yesterday;
    }

    // Walk backwards through completions
    for (final date in sortedDates) {
      final normalizedDate = AppDateUtils.startOfDay(date);

      if (AppDateUtils.isSameDay(normalizedDate, expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(expectedDate)) {
        // Gap found - break streak
        break;
      }
      // Skip duplicate dates (same day, multiple completions)
    }

    return streak;
  }

  /// Calculate longest streak from all completion dates
  static int calculateLongestStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    // Remove duplicates and sort ascending
    final uniqueDates =
        completionDates.map((d) => AppDateUtils.startOfDay(d)).toSet().toList()
          ..sort();

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < uniqueDates.length; i++) {
      final daysDiff = AppDateUtils.daysBetween(
        uniqueDates[i - 1],
        uniqueDates[i],
      );

      if (daysDiff == 1) {
        // Consecutive days
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Gap - reset streak
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // ============================================================================
  // STREAK STATUS CHECKS
  // ============================================================================

  /// Check if streak is active (completed today or yesterday)
  static bool isStreakActive(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return false;

    final today = AppDateUtils.today;
    final yesterday = AppDateUtils.yesterday;

    return completionDates.any((date) {
      final normalized = AppDateUtils.startOfDay(date);
      return AppDateUtils.isSameDay(normalized, today) ||
          AppDateUtils.isSameDay(normalized, yesterday);
    });
  }

  /// Check if completed today
  static bool isCompletedToday(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return false;
    final today = AppDateUtils.today;
    return completionDates.any((date) => AppDateUtils.isSameDay(date, today));
  }

  /// Check if completed yesterday
  static bool isCompletedYesterday(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return false;
    final yesterday = AppDateUtils.yesterday;
    return completionDates.any(
      (date) => AppDateUtils.isSameDay(date, yesterday),
    );
  }

  // ============================================================================
  // DECAY CALCULATION
  // ============================================================================

  /// Calculate consecutive days missed
  static int calculateDaysMissed(DateTime? lastCompletionDate) {
    if (lastCompletionDate == null) return 0;

    final lastCompletion = AppDateUtils.startOfDay(lastCompletionDate);
    final today = AppDateUtils.today;

    // If completed today, no days missed
    if (AppDateUtils.isSameDay(lastCompletion, today)) return 0;

    // Calculate days between last completion and today
    final daysMissed = AppDateUtils.daysBetween(lastCompletion, today) - 1;
    return daysMissed > 0 ? daysMissed : 0;
  }

  /// Calculate hours until streak breaks
  static int calculateDecayHours(DateTime? lastCompletionDate) {
    if (lastCompletionDate == null) return 0;

    final lastCompletion = AppDateUtils.startOfDay(lastCompletionDate);
    final today = AppDateUtils.today;

    // If completed today, hours until tomorrow midnight
    if (AppDateUtils.isSameDay(lastCompletion, today)) {
      return AppDateUtils.getHoursUntilMidnight();
    }

    // If completed yesterday, streak expires at end of today
    if (AppDateUtils.isSameDay(lastCompletion, AppDateUtils.yesterday)) {
      return AppDateUtils.getHoursUntilMidnight();
    }

    // Streak already broken
    return 0;
  }

  // ============================================================================
  // GRACE PERIOD (Technical Addendum)
  // ============================================================================

  /// Check if completion is within grace period (3 hours after midnight)
  static bool isGracePeriodActive(DateTime? lastCompletionDate) {
    if (lastCompletionDate == null) return false;
    return AppDateUtils.isWithinGracePeriod(lastCompletionDate);
  }

  // ============================================================================
  // COMPLETION ANALYSIS
  // ============================================================================

  /// Get completion count for a specific date range
  static int getCompletionCount(
    List<DateTime> completionDates,
    DateTime startDate,
    DateTime endDate,
  ) {
    final start = AppDateUtils.startOfDay(startDate);
    final end = AppDateUtils.startOfDay(endDate);

    return completionDates.where((date) {
      final normalized = AppDateUtils.startOfDay(date);
      return !normalized.isBefore(start) && !normalized.isAfter(end);
    }).length;
  }

  /// Get completion dates within last N days
  static List<DateTime> getRecentCompletions(
    List<DateTime> completionDates,
    int days,
  ) {
    final cutoff = AppDateUtils.subtractDays(AppDateUtils.today, days);
    return completionDates
        .where((date) => !AppDateUtils.isBeforeDay(date, cutoff))
        .toList();
  }

  /// Calculate weekly completion rate (0.0 to 1.0)
  static double calculateWeeklyCompletionRate(List<DateTime> completionDates) {
    final weekStart = AppDateUtils.getWeekStart(AppDateUtils.now);
    final weekEnd = AppDateUtils.getWeekEnd(AppDateUtils.now);

    final completionsThisWeek = getCompletionCount(
      completionDates,
      weekStart,
      weekEnd,
    );

    return completionsThisWeek / 7.0;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get next milestone days (7 or 30)
  static int? getNextMilestone(int currentStreak) {
    if (currentStreak < 7) return 7;
    if (currentStreak < 30) return 30;
    return null; // No more milestones
  }

  /// Days until next milestone
  static int? daysUntilNextMilestone(int currentStreak) {
    final nextMilestone = getNextMilestone(currentStreak);
    if (nextMilestone == null) return null;
    return nextMilestone - currentStreak;
  }

  /// Check if streak qualifies for XP bonus
  static bool qualifiesForMilestoneBonus(int streakDays) {
    return streakDays == 7 || streakDays == 30;
  }
}
