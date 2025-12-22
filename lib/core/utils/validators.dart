import '../constants/app_constants.dart';

/// Habit Island Input Validators
/// Provides validation methods for all user inputs.
///
/// Returns null if valid, error message string if invalid.
class Validators {
  Validators._();

  // ============================================================================
  // HABIT VALIDATION
  // ============================================================================

  /// Validate habit name per Product Documentation §3.1
  /// Requirements: 2-50 characters, alphanumeric + common punctuation
  static String? validateHabitName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Habit name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < AppConstants.habitNameMinLength) {
      return 'Habit name must be at least ${AppConstants.habitNameMinLength} characters';
    }

    if (trimmed.length > AppConstants.habitNameMaxLength) {
      return 'Habit name cannot exceed ${AppConstants.habitNameMaxLength} characters';
    }

    // Check for valid characters (alphanumeric + common punctuation)
    final validPattern = RegExp(AppConstants.habitNamePattern);
    if (!validPattern.hasMatch(trimmed)) {
      return 'Habit name contains invalid characters';
    }

    return null; // Valid
  }

  // ============================================================================
  // AUTHENTICATION VALIDATION
  // ============================================================================

  /// Validate email address format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();
    final emailRegex = RegExp(AppConstants.emailPattern);

    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  /// Validate password strength
  /// Requirements: At least 8 characters, 1 uppercase, 1 lowercase, 1 number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null; // Valid
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }

  // ============================================================================
  // GENERAL VALIDATION
  // ============================================================================

  /// Validate required field
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null; // Valid
  }

  /// Validate number range
  static String? validateNumberRange(
    String? value,
    int min,
    int max, {
    String fieldName = 'Value',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName must be a number';
    }

    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }

    return null; // Valid
  }

  // ============================================================================
  // TIME VALIDATION
  // ============================================================================

  /// Validate time format (HH:MM or H:MM)
  static String? validateTimeFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    // Accept both HH:MM and H:MM formats
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter time in HH:MM format (e.g., 09:30)';
    }

    return null; // Valid
  }

  // ============================================================================
  // URL VALIDATION
  // ============================================================================

  /// Validate URL format (optional field)
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null; // Valid
  }

  // ============================================================================
  // PHONE NUMBER VALIDATION
  // ============================================================================

  /// Validate phone number (optional field, basic validation)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value) ||
        value.replaceAll(RegExp(r'\D'), '').length < 10) {
      return 'Please enter a valid phone number';
    }

    return null; // Valid
  }

  // ============================================================================
  // HABIT-SPECIFIC VALIDATION
  // ============================================================================

  /// Validate habit frequency value
  /// For "X times per week" frequency
  static String? validateFrequencyValue(int? value) {
    if (value == null) {
      return 'Frequency is required';
    }

    if (value < 1 || value > 7) {
      return 'Frequency must be between 1 and 7 times per week';
    }

    return null; // Valid
  }

  /// Validate habit category selection
  static String? validateCategory(String? category) {
    if (category == null || category.isEmpty) {
      return 'Please select a category';
    }

    final validCategories = ['water', 'exercise', 'reading', 'meditation'];
    if (!validCategories.contains(category.toLowerCase())) {
      return 'Invalid category selected';
    }

    return null; // Valid
  }

  // ============================================================================
  // PREMIUM VALIDATION
  // ============================================================================

  /// Check if user has reached free tier habit limit
  static String? validateHabitLimit(int currentHabits, bool isPremium) {
    if (isPremium) {
      if (currentHabits >= AppConstants.maxHabitsPremium) {
        return 'Maximum habit limit reached';
      }
      return null;
    }

    if (currentHabits >= AppConstants.maxHabitsFree) {
      return 'Free tier limit reached. Upgrade to Premium for unlimited habits.';
    }

    return null; // Valid
  }

  // ============================================================================
  // FILE UPLOAD VALIDATION
  // ============================================================================

  /// Validate uploaded icon file size
  static String? validateIconFileSize(int fileSizeBytes) {
    if (fileSizeBytes > AppConstants.maxIconFileSizeBytes) {
      final maxSizeMB = AppConstants.maxIconFileSizeBytes / 1048576;
      return 'File size must be less than ${maxSizeMB.toStringAsFixed(1)} MB';
    }
    return null; // Valid
  }

  /// Validate image file extension
  static String? validateImageExtension(String filename) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = filename.toLowerCase().substring(
      filename.lastIndexOf('.'),
    );

    if (!validExtensions.contains(extension)) {
      return 'Invalid file type. Allowed: JPG, PNG, GIF, WebP';
    }

    return null; // Valid
  }

  // ============================================================================
  // COMPOSITE VALIDATION
  // ============================================================================

  /// Validate complete habit form
  static Map<String, String> validateHabitForm({
    required String? name,
    required String? category,
    String? reminderTime,
  }) {
    final errors = <String, String>{};

    final nameError = validateHabitName(name);
    if (nameError != null) errors['name'] = nameError;

    final categoryError = validateCategory(category);
    if (categoryError != null) errors['category'] = categoryError;

    if (reminderTime != null && reminderTime.isNotEmpty) {
      final timeError = validateTimeFormat(reminderTime);
      if (timeError != null) errors['reminderTime'] = timeError;
    }

    return errors;
  }

  /// Validate complete signup form
  static Map<String, String> validateSignupForm({
    required String? email,
    required String? password,
    required String? passwordConfirmation,
  }) {
    final errors = <String, String>{};

    final emailError = validateEmail(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) errors['password'] = passwordError;

    final confirmError = validatePasswordConfirmation(
      password,
      passwordConfirmation,
    );
    if (confirmError != null) errors['passwordConfirmation'] = confirmError;

    return errors;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if form has any errors
  static bool hasErrors(Map<String, String> errors) {
    return errors.isNotEmpty;
  }

  /// Get first error message from errors map
  static String? getFirstError(Map<String, String> errors) {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }
}
