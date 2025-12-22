/// String extensions for common operations
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is email
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is valid URL
  bool get isUrl {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Check if string contains only numbers
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Reverse string
  String get reversed => split('').reversed.join();

  /// Count occurrences of substring
  int count(String substring) {
    if (substring.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = indexOf(substring, index)) != -1) {
      count++;
      index += substring.length;
    }
    return count;
  }

  /// Check if string is empty or whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not empty and not whitespace
  bool get isNotBlank => !isBlank;

  /// Remove HTML tags
  String get removeHtmlTags => replaceAll(RegExp(r'<[^>]*>'), '');

  /// Convert to slug (URL-friendly)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// Extract initials (e.g., "John Doe" -> "JD")
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Parse to DateTime (ISO 8601)
  DateTime? get toDateTime {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Mask sensitive data (e.g., email, phone)
  String mask({int visibleChars = 3, String maskChar = '*'}) {
    if (length <= visibleChars * 2) return this;
    final start = substring(0, visibleChars);
    final end = substring(length - visibleChars);
    final middle = maskChar * (length - visibleChars * 2);
    return '$start$middle$end';
  }

  // ============================================================================
  // HABIT ISLAND SPECIFIC EXTENSIONS
  // ============================================================================

  /// Format as habit name (capitalized words)
  String get asHabitName => trim().capitalizeWords;

  /// Format as XP display (e.g., "1234" → "1,234 XP")
  String get asXpDisplay {
    final number = int.tryParse(this);
    if (number == null) return this;
    return '${_formatWithCommas(number)} XP';
  }

  /// Format number with commas
  String _formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// Mask email keeping first 3 chars and domain
  String get maskedEmail {
    if (!isEmail) return this;
    final parts = split('@');
    if (parts.length != 2) return this;

    final username = parts[0];
    final domain = parts[1];
    final masked = username.length > 3
        ? '${username.substring(0, 3)}***'
        : '$username***';

    return '$masked@$domain';
  }

  /// Check if valid habit name (2-50 chars, alphanumeric + common punctuation)
  bool get isValidHabitName {
    if (length < 2 || length > 50) return false;
    final pattern = RegExp(r'^[a-zA-Z0-9\s\-_,.!?]+$');
    return pattern.hasMatch(this);
  }

  /// Convert to camel case
  String get toCamelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words.skip(1).map((word) => word.capitalize).join();
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[\s-]+'), '_').replaceFirst(RegExp(r'^_'), '');
  }

  /// Try parse as int
  int? get tryParseInt => int.tryParse(this);

  /// Try parse as double
  double? get tryParseDouble => double.tryParse(this);
}

/// Nullable String extensions
extension NullableStringExtensions on String? {
  /// Check if null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if null or blank (empty or whitespace)
  bool get isNullOrBlank => this == null || this!.isBlank;

  /// Get or default
  String orDefault(String defaultValue) => this ?? defaultValue;

  /// Get or empty string
  String get orEmpty => this ?? '';
}
