/// List extensions for collection operations
extension ListExtensions<T> on List<T> {
  // ============================================================================
  // SAFE ACCESS
  // ============================================================================

  /// Get element at index safely, return null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get element at index or default value
  T getOrElse(int index, T defaultValue) {
    return getOrNull(index) ?? defaultValue;
  }

  /// Get first element or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  // ============================================================================
  // GROUPING & PARTITIONING
  // ============================================================================

  /// Group elements by a key selector
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  /// Partition list into two lists based on predicate
  /// Returns [matching, notMatching]
  List<List<T>> partition(bool Function(T) predicate) {
    final matching = <T>[];
    final notMatching = <T>[];

    for (final element in this) {
      if (predicate(element)) {
        matching.add(element);
      } else {
        notMatching.add(element);
      }
    }

    return [matching, notMatching];
  }

  /// Split list into chunks of specified size
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    if (isEmpty) return [];

    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  // ============================================================================
  // DISTINCT & UNIQUE
  // ============================================================================

  /// Get distinct elements (removes duplicates)
  List<T> get distinct => toSet().toList();

  /// Get distinct elements by key
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    final result = <T>[];

    for (final element in this) {
      final key = keySelector(element);
      if (seen.add(key)) {
        result.add(element);
      }
    }

    return result;
  }

  // ============================================================================
  // SORTING
  // ============================================================================

  /// Sort by key selector (ascending)
  List<T> sortedBy<K extends Comparable>(K Function(T) keySelector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keySelector(a).compareTo(keySelector(b)));
    return copy;
  }

  /// Sort by key selector (descending)
  List<T> sortedByDescending<K extends Comparable>(K Function(T) keySelector) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keySelector(b).compareTo(keySelector(a)));
    return copy;
  }

  // ============================================================================
  // FINDING
  // ============================================================================

  /// Find first element matching predicate, or null
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  /// Find last element matching predicate, or null
  T? lastWhereOrNull(bool Function(T) test) {
    try {
      return lastWhere(test);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // AGGREGATION
  // ============================================================================

  /// Sum of numeric values
  num sum(num Function(T) selector) {
    if (isEmpty) return 0;
    return map(selector).reduce((a, b) => a + b);
  }

  /// Average of numeric values
  double average(num Function(T) selector) {
    if (isEmpty) return 0;
    return sum(selector) / length;
  }

  /// Maximum value
  T? maxBy<K extends Comparable>(K Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) > 0 ? a : b);
  }

  /// Minimum value
  T? minBy<K extends Comparable>(K Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) < 0 ? a : b);
  }

  // ============================================================================
  // TRANSFORMATION
  // ============================================================================

  /// Map with index
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) {
    return Iterable.generate(length, (i) => transform(i, this[i]));
  }

  /// Filter and map in one operation
  Iterable<R> filterMap<R>(R? Function(T) transform) {
    return map(transform).where((element) => element != null).cast<R>();
  }

  // ============================================================================
  // HABIT ISLAND SPECIFIC
  // ============================================================================

  /// Get completion rate (count of matching items / total)
  double completionRate(bool Function(T) isCompleted) {
    if (isEmpty) return 0.0;
    final completedCount = where(isCompleted).length;
    return completedCount / length;
  }

  /// Get percentage of items matching condition
  double percentage(bool Function(T) predicate) {
    if (isEmpty) return 0.0;
    return (where(predicate).length / length) * 100;
  }

  /// Count items matching predicate
  int countWhere(bool Function(T) predicate) {
    return where(predicate).length;
  }
}

/// DateTime List Extensions (for habit completions)
extension DateTimeListExtensions on List<DateTime> {
  /// Get unique dates (normalized to day)
  List<DateTime> get uniqueDates {
    return map(
      (date) => DateTime(date.year, date.month, date.day),
    ).toSet().toList();
  }

  /// Sort dates ascending
  List<DateTime> get sortedAscending {
    final copy = List<DateTime>.from(this);
    copy.sort();
    return copy;
  }

  /// Sort dates descending
  List<DateTime> get sortedDescending {
    final copy = List<DateTime>.from(this);
    copy.sort((a, b) => b.compareTo(a));
    return copy;
  }

  /// Get dates within last N days
  List<DateTime> withinLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffDay = DateTime(cutoff.year, cutoff.month, cutoff.day);
    return where((date) {
      final dateDay = DateTime(date.year, date.month, date.day);
      return dateDay.isAfter(cutoffDay) || dateDay.isAtSameMomentAs(cutoffDay);
    }).toList();
  }

  /// Count completions per day
  Map<DateTime, int> get completionsPerDay {
    final normalized = map((date) => DateTime(date.year, date.month, date.day));
    final counts = <DateTime, int>{};

    for (final date in normalized) {
      counts[date] = (counts[date] ?? 0) + 1;
    }

    return counts;
  }

  /// Get longest consecutive streak
  int get longestConsecutiveStreak {
    if (isEmpty) return 0;

    final unique = uniqueDates.sortedAscending;
    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < unique.length; i++) {
      final diff = unique[i].difference(unique[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  /// Get current streak from most recent date
  int get currentStreak {
    if (isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final unique = uniqueDates.sortedDescending;
    final lastDate = unique.first;

    // Check if streak is broken (no completion today or yesterday)
    if (!lastDate.isAtSameMomentAs(today) &&
        !lastDate.isAtSameMomentAs(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = lastDate.isAtSameMomentAs(today)
        ? today
        : yesterday;

    for (final date in unique) {
      if (date.isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(expectedDate)) {
        break;
      }
    }

    return streak;
  }

  /// Check if completed today
  bool get hasCompletionToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return any((date) {
      final dateDay = DateTime(date.year, date.month, date.day);
      return dateDay.isAtSameMomentAs(today);
    });
  }

  /// Get completion dates for a specific month
  List<DateTime> forMonth(int year, int month) {
    return where((date) => date.year == year && date.month == month).toList();
  }

  /// Get completion dates for a specific week
  List<DateTime> forWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return where((date) {
      final dateDay = DateTime(date.year, date.month, date.day);
      return (dateDay.isAfter(start) || dateDay.isAtSameMomentAs(start)) &&
          dateDay.isBefore(end);
    }).toList();
  }
}

/// Nullable List Extensions
extension NullableListExtensions<T> on List<T>? {
  /// Check if null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Get length or 0 if null
  int get lengthOrZero => this?.length ?? 0;

  /// Get list or empty list if null
  List<T> get orEmpty => this ?? [];
}
