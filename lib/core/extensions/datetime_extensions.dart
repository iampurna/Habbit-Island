import 'package:intl/intl.dart';

/// DateTime extensions for common date operations
extension DateTimeExtensions on DateTime {
  /// Check if this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if this date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if this date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    return startOfDay.subtract(Duration(days: weekday - 1));
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    return startOfDay.add(Duration(days: 7 - weekday));
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Format as "MMM dd, yyyy"
  String get formatted => DateFormat('MMM dd, yyyy').format(this);

  /// Format as "EEEE, MMM dd"
  String get formattedLong => DateFormat('EEEE, MMM dd').format(this);

  /// Format as time "hh:mm a"
  String get timeFormatted => DateFormat('hh:mm a').format(this);

  /// Format as full datetime
  String get fullFormatted =>
      DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(this);

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (isToday) {
      return 'Today';
    } else if (isYesterday) {
      return 'Yesterday';
    } else if (isTomorrow) {
      return 'Tomorrow';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Days until this date
  int daysUntil() {
    final now = DateTime.now();
    return startOfDay.difference(now.startOfDay).inDays;
  }

  /// Days since this date
  int daysSince() {
    final now = DateTime.now();
    return now.startOfDay.difference(startOfDay).inDays;
  }

  // ============================================================================
  // HABIT ISLAND SPECIFIC EXTENSIONS
  // ============================================================================

  /// Check if within grace period (3 hours after midnight)
  /// Reference: Technical Addendum §3.3
  bool get isWithinGracePeriod {
    final dayStart = startOfDay;
    final gracePeriodEnd = dayStart.add(const Duration(hours: 3));
    return isAfter(dayStart) && isBefore(gracePeriodEnd);
  }

  /// Get logical completion date (considers grace period for streaks)
  DateTime get logicalCompletionDate {
    if (isWithinGracePeriod) {
      return startOfDay.subtract(const Duration(days: 1));
    }
    return startOfDay;
  }

  /// Hours until midnight
  int get hoursUntilMidnight {
    final now = DateTime.now();
    final nextMidnight = now.startOfDay.add(const Duration(days: 1));
    return nextMidnight.difference(now).inHours;
  }

  /// Day of week name
  String get dayOfWeekName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  /// Short day of week name
  String get dayOfWeekShort {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Month name
  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Short month name
  String get monthNameShort {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Check if weekend
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if weekday
  bool get isWeekday => !isWeekend;
}
