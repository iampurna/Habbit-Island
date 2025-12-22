import 'package:intl/intl.dart';

/// Habit Island Date & Time Utilities
/// CRITICAL: This handles timezone-aware date operations for global users.
/// All streak calculations MUST use logical dates in user's timezone.
class AppDateUtils {
  AppDateUtils._();

  // ============================================================================
  // CURRENT TIME GETTERS
  // ============================================================================

  static DateTime get now => DateTime.now();
  static DateTime get nowUtc => DateTime.now().toUtc();
  static DateTime get today => startOfDay(now);
  static DateTime get yesterday => today.subtract(const Duration(days: 1));

  // ============================================================================
  // DAY BOUNDARIES
  // ============================================================================

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfTomorrow([DateTime? date]) {
    final base = date ?? now;
    return startOfDay(base).add(const Duration(days: 1));
  }

  // ============================================================================
  // DATE COMPARISON
  // ============================================================================

  static bool isToday(DateTime date) => isSameDay(date, today);
  static bool isYesterday(DateTime date) => isSameDay(date, yesterday);

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isBeforeDay(DateTime date1, DateTime date2) {
    return startOfDay(date1).isBefore(startOfDay(date2));
  }

  static bool isAfterDay(DateTime date1, DateTime date2) {
    return startOfDay(date1).isAfter(startOfDay(date2));
  }

  // ============================================================================
  // DATE CALCULATIONS
  // ============================================================================

  static int daysBetween(DateTime from, DateTime to) {
    return startOfDay(to).difference(startOfDay(from)).inDays;
  }

  static DateTime addDays(DateTime date, int days) =>
      date.add(Duration(days: days));
  static DateTime subtractDays(DateTime date, int days) =>
      date.subtract(Duration(days: days));

  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (current.isBefore(endDate) || isSameDay(current, endDate)) {
      dates.add(current);
      current = addDays(current, 1);
    }
    return dates;
  }

  // ============================================================================
  // WEEK OPERATIONS
  // ============================================================================

  static DateTime getWeekStart(DateTime date) {
    return startOfDay(date.subtract(Duration(days: date.weekday - 1)));
  }

  static DateTime getWeekEnd(DateTime date) {
    return endOfDay(
      date.add(Duration(days: DateTime.daysPerWeek - date.weekday)),
    );
  }

  static List<DateTime> getCurrentWeek() {
    final weekStart = getWeekStart(now);
    return List.generate(7, (index) => addDays(weekStart, index));
  }

  // ============================================================================
  // MONTH OPERATIONS
  // ============================================================================

  static DateTime getMonthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);
  static DateTime getMonthEnd(DateTime date) =>
      endOfDay(DateTime(date.year, date.month + 1, 0));
  static int getDaysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  // ============================================================================
  // FORMATTING
  // ============================================================================

  static String formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);
  static String formatDateLong(DateTime date) =>
      DateFormat('EEEE, MMM dd').format(date);
  static String formatTime(DateTime time) => DateFormat('h:mm a').format(time);
  static String formatDateTime(DateTime dt) =>
      DateFormat("MMM dd, yyyy 'at' h:mm a").format(dt);
  static String formatIsoDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';

    final days = daysBetween(date, now);
    if (days == -1) return 'Tomorrow';
    if (days < 0) return 'In ${-days} days';
    if (days < 7) return '$days ${days == 1 ? 'day' : 'days'} ago';

    final weeks = (days / 7).floor();
    if (weeks < 4) return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';

    final months = (days / 30).floor();
    if (months < 12) return '$months ${months == 1 ? 'month' : 'months'} ago';

    final years = (days / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  // ============================================================================
  // PARSING
  // ============================================================================

  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseIsoDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    } catch (e) {
      // Fall through
    }
    return null;
  }

  static String toIso8601(DateTime date) => date.toIso8601String();

  // ============================================================================
  // STREAK-SPECIFIC HELPERS
  // ============================================================================

  /// Grace period: 3 hours after midnight (Technical Addendum)
  static bool isWithinGracePeriod(DateTime completionTime) {
    final dayStart = startOfDay(completionTime);
    final gracePeriodEnd = dayStart.add(const Duration(hours: 3));
    return completionTime.isAfter(dayStart) &&
        completionTime.isBefore(gracePeriodEnd);
  }

  /// Get logical completion date (considers grace period)
  static DateTime getLogicalCompletionDate(DateTime completionTime) {
    if (isWithinGracePeriod(completionTime)) {
      return startOfDay(completionTime.subtract(const Duration(days: 1)));
    }
    return startOfDay(completionTime);
  }

  static int getHoursUntilMidnight([DateTime? fromTime]) {
    final current = fromTime ?? now;
    final nextMidnight = startOfTomorrow(current);
    return nextMidnight.difference(current).inHours;
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  static bool isPast(DateTime date) => isBeforeDay(date, today);
  static bool isFuture(DateTime date) => isAfterDay(date, today);
  static bool isWithinLastDays(DateTime date, int days) {
    return !isBeforeDay(date, subtractDays(today, days));
  }
}
