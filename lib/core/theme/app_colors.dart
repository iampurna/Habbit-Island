import 'package:flutter/material.dart';

/// Habit Island Color Palette
/// This class defines all color tokens used throughout the application.
/// Colors are organized by their semantic purpose rather than visual appearance.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================
  /// Primary brand color - Main actions, active states, links, primary buttons
  static const Color primary = Color(0xFF6B9AC4);

  /// Secondary brand color - Success states, completed habits, growth indicators
  static const Color secondary = Color(0xFF97D8C4);

  /// Accent color - Highlights, streaks, XP indicators, premium badges
  static const Color accent = Color(0xFFF4A261);
  static const Color accentLight = Color(0xFFFFC975);
  static const Color accentDark = Color(0xFFFF9919);
  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  /// Success color - Habit completion, positive feedback, checkmarks
  static const Color success = Color(0xFF6BCF7F);
  static const Color info = Color(0xFF2196F3);

  /// Warning color - Missed habits, alerts, decay warnings
  static const Color warning = Color(0xFFF4C261);

  /// Danger color - Errors, streak loss, storm states, delete actions
  static const Color error = Color(0xFFF44336);
  static const Color danger = Color(0xFFE76F51);

  // ============================================================================
  // NEUTRAL COLORS
  // ============================================================================
  /// Background color - App background, off-white canvas
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundLight = Color(0xFFF5F9FC);
  static const Color backgroundDark = Color(0xFF1A1F2E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF252B3B);

  /// Primary text color - Headlines, body text, primary content
  static const Color textPrimary = Color(0xFF2D3748);

  /// Secondary text color - Captions, hints, secondary information
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1F2E);

  // ============================================================================
  // COMPONENT-SPECIFIC COLORS
  // ============================================================================
  /// Card background - Pure white for elevated cards
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Border color - Default borders for inputs and cards
  static const Color border = Color(0xFFE2E8F0);

  /// Divider color - Subtle separators
  static const Color divider = Color(0xFFE2E8F0);

  // ============================================================================
  // STATE VARIATIONS
  // ============================================================================
  /// Primary color with opacity for hover/pressed states
  static Color get primaryLight => primary.withAlpha(31);
  static Color get primaryDark => const Color(0xFF5A8AB3);

  /// Success variations for different states
  static Color get successLight => success.withAlpha(31);
  static Color get successDark => const Color(0xFF5ABF6F);

  /// Warning variations
  static Color get warningLight => warning.withAlpha(31);
  static Color get warningDark => const Color(0xFFE4B251);

  /// Danger variations
  static Color get dangerLight => danger.withAlpha(31);
  static Color get dangerDark => const Color(0xFFD75F41);

  // ============================================================================
  // OVERLAY COLORS
  // ============================================================================
  /// Black overlay for modals and bottom sheets
  static Color get overlay => Colors.black.withAlpha(31);
  // Shadow & Overlay
  static const Color shadow = Color(0x1A000000);

  /// Scrim for dimmed backgrounds
  static Color get scrim => Colors.black.withAlpha(31);

  // ============================================================================
  // GRADIENT DEFINITIONS
  // ============================================================================
  /// Splash screen gradient (Primary → Secondary)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary],
  );

  /// Success gradient for celebration effects
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, secondary],
  );

  /// Premium gradient for premium features
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primary],
  );

  // ============================================================================
  // SHADOW DEFINITIONS
  // ============================================================================
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(31),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // ============================================================================
  // ISLAND-SPECIFIC COLORS
  // ============================================================================
  /// Ocean gradient colors for island background
  static const Color oceanLight = Color(0xFF97D8C4);
  static const Color oceanDark = Color(0xFF6B9AC4);

  /// Weather state colors
  static const Color weatherRainbow = accent;
  static const Color weatherSunny = Color(0xFFFDB813);
  static const Color weatherCloudy = Color(0xFFB0B8C1);
  static const Color weatherStormy = Color(0xFF5A6872);

  //Island Theme colors
  static const Color islandGreen = Color(0xFF7CB342);
  static const Color oceanBlue = Color(0xFF42A5F5);
  static const Color sandBeige = Color(0xFFFFE082);
  static const Color skyBlue = Color(0xFF81D4FA);

  // Habit Category Colors
  static const Color waterCategory = Color(0xFF0288D1);
  static const Color exerciseCategory = Color(0xFFE53935);
  static const Color readingCategory = Color(0xFF6A1B9A);
  static const Color meditationCategory = Color(0xFF00897B);
  static const Color healthCategory = Color(0xFFFB8C00);
  static const Color productivityCategory = Color(0xFF5E35B1);

  // Streak & Progress Colors
  static const Color streakFire = Color(0xFFFF6F00);
  static const Color progressIncomplete = Color(0xFFE0E0E0);
  static const Color progressComplete = Color(0xFF4CAF50);

  // Premium Colors
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumGradientStart = Color(0xFFFFD700);
  static const Color premiumGradientEnd = Color(0xFFFF8C00);
}
