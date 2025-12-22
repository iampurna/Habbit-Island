import 'dart:math' as math;

/// Num extensions for number operations
extension NumExtensions on num {
  // ============================================================================
  // FORMATTING
  // ============================================================================

  /// Format as currency (USD)
  String get toCurrency => '\$${toStringAsFixed(2)}';

  /// Format with thousands separator
  String get withCommas {
    final parts = toString().split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final formatted = intPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return '$formatted$decimalPart';
  }

  /// Format as percentage (e.g., 0.75 → "75%")
  String get asPercentage => '${(this * 100).toStringAsFixed(0)}%';

  /// Format as percentage with decimals
  String asPercentageWithDecimals(int decimals) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Format with K/M suffix (e.g., 1000 → "1K", 1500000 → "1.5M")
  String get withSuffix {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Format to fixed decimal places
  String toFixed(int decimals) => toStringAsFixed(decimals);

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Check if number is between min and max (inclusive)
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Check if number is even
  bool get isEven => this % 2 == 0;

  /// Check if number is odd
  bool get isOdd => !isEven;

  // ============================================================================
  // MATHEMATICAL OPERATIONS
  // ============================================================================

  /// Square this number
  num get squared => this * this;

  /// Cube this number
  num get cubed => this * this * this;

  /// Calculate power
  num pow(num exponent) => math.pow(this, exponent);

  /// Calculate square root
  double get sqrt => math.sqrt(toDouble());

  /// Calculate absolute value
  num get absolute => abs();

  /// Get sign (-1, 0, or 1)
  int get sign => compareTo(0);

  /// Clamp to range
  num clampTo(num min, num max) => clamp(min, max);

  // ============================================================================
  // PERCENTAGES
  // ============================================================================

  /// Calculate percentage of a value (e.g., 50.percentOf(200) = 100)
  double percentOf(num total) => (this / 100) * total;

  /// Calculate what percentage this is of total (e.g., 50.percentageOf(200) = 25)
  double percentageOf(num total) => total == 0 ? 0 : (this / total) * 100;

  /// Increase by percentage (e.g., 100.increaseBy(10) = 110)
  double increaseBy(num percentage) => toDouble() * (1 + percentage / 100);

  /// Decrease by percentage (e.g., 100.decreaseBy(10) = 90)
  double decreaseBy(num percentage) => toDouble() * (1 - percentage / 100);

  // ============================================================================
  // HABIT ISLAND SPECIFIC
  // ============================================================================

  /// Format as XP display (e.g., 1234 → "1,234 XP")
  String get asXp => '$withCommas XP';

  /// Format as streak display (e.g., 7 → "7🔥")
  String get asStreak => '$this🔥';

  /// Format as completion rate (e.g., 0.75 → "75%")
  String get asCompletionRate => asPercentage;

  /// Calculate XP progress (returns 0.0 to 1.0)
  double progressTowards(num target) {
    if (target == 0) return 0.0;
    return (this / target).clamp(0.0, 1.0).toDouble();
  }

  /// Check if milestone (7, 30, 60, 90, 180, 365)
  bool get isMilestone {
    return this == 7 ||
        this == 30 ||
        this == 60 ||
        this == 90 ||
        this == 180 ||
        this == 365;
  }

  /// Get next milestone
  int? get nextMilestone {
    if (this < 7) return 7;
    if (this < 30) return 30;
    if (this < 60) return 60;
    if (this < 90) return 90;
    if (this < 180) return 180;
    if (this < 365) return 365;
    return null;
  }

  /// Days until next milestone
  int? get daysUntilNextMilestone {
    final next = nextMilestone;
    if (next == null) return null;
    return (next - toInt()).clamp(0, double.infinity).toInt();
  }

  /// Format as level display (e.g., 5 → "Level 5")
  String get asLevel => 'Level $this';

  /// Format completion rate with percentage
  String get asCompletionPercentage {
    return '${(this * 100).toStringAsFixed(0)}% Complete';
  }

  /// Get weather emoji based on completion rate
  String get weatherEmoji {
    if (this >= 1.0) return '🌈';
    if (this >= 0.75) return '☀️';
    if (this >= 0.50) return '⛅';
    if (this >= 0.25) return '☁️';
    return '⛈️';
  }
}

/// Int extensions
extension IntExtensions on int {
  // ============================================================================
  // PLURALIZATION
  // ============================================================================

  /// Pluralize a word based on count
  /// Example: 1.plural('day') = "1 day", 2.plural('day') = "2 days"
  String plural(String singular, [String? plural]) {
    final pluralForm = plural ?? '${singular}s';
    return '$this ${this == 1 ? singular : pluralForm}';
  }

  // ============================================================================
  // ORDINAL
  // ============================================================================

  /// Get ordinal suffix (1st, 2nd, 3rd, 4th, etc.)
  String get ordinal {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }

    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  // ============================================================================
  // ITERATION
  // ============================================================================

  /// Iterate from 0 to this number - 1
  /// Example: 5.times((i) => print(i)) prints 0,1,2,3,4
  void times(void Function(int index) action) {
    for (int i = 0; i < this; i++) {
      action(i);
    }
  }

  /// Generate list by repeating action
  /// Example: 3.generate((i) => i * 2) returns [0, 2, 4]
  List<T> generate<T>(T Function(int index) generator) {
    return List.generate(this, generator);
  }

  // ============================================================================
  // ROMAN NUMERALS (for levels, etc.)
  // ============================================================================

  /// Convert to Roman numeral (1-3999)
  String get toRoman {
    if (this < 1 || this > 3999) return toString();

    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const numerals = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I',
    ];

    var result = '';
    var num = this;

    for (int i = 0; i < values.length; i++) {
      while (num >= values[i]) {
        num -= values[i];
        result += numerals[i];
      }
    }

    return result;
  }

  // ============================================================================
  // HABIT ISLAND SPECIFIC
  // ============================================================================

  /// Format as growth stage
  String get asGrowthStage {
    if (this == 1) return 'Level 1 (Seedling)';
    if (this == 2) return 'Level 2 (Thriving)';
    if (this == 3) return 'Level 3 (Flourishing)';
    return 'Level $this';
  }

  /// Check if valid habit count
  bool get isValidHabitCount => this >= 1 && this <= 999;

  /// Format time duration (assumes minutes)
  String get asMinutes => '$this ${this == 1 ? 'minute' : 'minutes'}';

  /// Format time duration (assumes hours)
  String get asHours => '$this ${this == 1 ? 'hour' : 'hours'}';

  /// Format time duration (assumes days)
  String get asDays => '$this ${this == 1 ? 'day' : 'days'}';

  /// Format as XP with commas
  String get asXpFormatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

/// Double extensions
extension DoubleExtensions on double {
  // ============================================================================
  // PRECISION
  // ============================================================================

  /// Round to N decimal places
  double roundToDecimal(int places) {
    final mod = math.pow(10, places);
    return (this * mod).round() / mod;
  }

  /// Check if approximately equal (with tolerance)
  bool approximatelyEquals(double other, {double tolerance = 0.0001}) {
    return (this - other).abs() < tolerance;
  }

  // ============================================================================
  // INTERPOLATION
  // ============================================================================

  /// Linear interpolation between two values
  /// t should be between 0.0 and 1.0
  double lerp(double target, double t) {
    return this + (target - this) * t.clamp(0.0, 1.0);
  }

  // ============================================================================
  // HABIT ISLAND SPECIFIC
  // ============================================================================

  /// Get weather condition name based on completion rate
  String get weatherCondition {
    if (this >= 1.0) return 'Rainbow';
    if (this >= 0.75) return 'Sunny';
    if (this >= 0.50) return 'Partly Cloudy';
    if (this >= 0.25) return 'Cloudy';
    return 'Stormy';
  }

  /// Format as rating (e.g., 4.5 → "4.5 ⭐")
  String get asRating => '$this ⭐';

  /// Format completion percentage with emoji
  String get asCompletionWithEmoji {
    return '${(this * 100).toStringAsFixed(0)}% $weatherEmoji';
  }
}

/// Nullable Num extensions
extension NullableNumExtensions on num? {
  /// Get value or zero if null
  num get orZero => this ?? 0;

  /// Get value or default if null
  num orDefault(num defaultValue) => this ?? defaultValue;

  /// Check if null or zero
  bool get isNullOrZero => this == null || this == 0;
}
