import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Habit Island Typography System
/// Defines the complete text style hierarchy for the application.
/// Uses Nunito for headings, Inter for body text, and JetBrains Mono for numbers.
class AppTypography {
  AppTypography._(); // Private constructor

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================

  static const String _nunitoFontFamily = 'Nunito';
  static const String _interFontFamily = 'Inter';
  static const String _jetBrainsMonoFontFamily = 'JetBrainsMono';

  // ============================================================================
  // DISPLAY STYLES
  // ============================================================================

  /// Display style - Nunito 32px Bold
  /// Usage: Island level, big numbers
  static const TextStyle display = TextStyle(
    fontFamily: _nunitoFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    height: 1.25, // 40px line height
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // HEADING STYLES
  // ============================================================================

  /// H1 - Nunito 24px Bold
  /// Usage: Screen titles
  static const TextStyle h1 = TextStyle(
    fontFamily: _nunitoFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    height: 1.33, // 32px line height
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// H2 - Nunito 20px SemiBold
  /// Usage: Section headers
  static const TextStyle h2 = TextStyle(
    fontFamily: _nunitoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.4, // 28px line height
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// H3 - Nunito 18px SemiBold (useful for subsections)
  static const TextStyle h3 = TextStyle(
    fontFamily: _nunitoFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.44, // 26px line height
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // BODY STYLES
  // ============================================================================

  /// Body - Inter 14px Regular
  /// Usage: Standard body text
  static const TextStyle body = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    height: 1.57, // 22px line height
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Medium - Inter 14px Medium
  /// Usage: Emphasized body text
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 1.57, // 22px line height
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Body Small - Inter 12px Regular
  /// Usage: Captions, hints, secondary information
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // 18px line height
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // NUMBER STYLES
  // ============================================================================

  /// Number - JetBrains Mono 16px Medium
  /// Usage: Stats, XP, streaks
  static const TextStyle number = TextStyle(
    fontFamily: _jetBrainsMonoFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5, // 24px line height
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  /// Number Large - JetBrains Mono 24px Medium
  /// Usage: Big statistics, XP counters
  static const TextStyle numberLarge = TextStyle(
    fontFamily: _jetBrainsMonoFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500, // Medium
    height: 1.33, // 32px line height
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  /// Number Small - JetBrains Mono 12px Medium
  /// Usage: Small counters, badges
  static const TextStyle numberSmall = TextStyle(
    fontFamily: _jetBrainsMonoFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    height: 1.5, // 18px line height
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // BUTTON TEXT STYLES
  // ============================================================================

  /// Button text - Inter 14px SemiBold
  /// Usage: Button labels, CTAs
  static const TextStyle button = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.43, // 20px line height
    letterSpacing: 0.5,
    color: Colors.white,
  );

  /// Button Large - Inter 16px SemiBold
  /// Usage: Primary CTAs
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.5, // 24px line height
    letterSpacing: 0.5,
    color: Colors.white,
  );

  // ============================================================================
  // LABEL STYLES
  // ============================================================================

  /// Label - Inter 12px SemiBold Uppercase
  /// Usage: Section labels, overlines
  static const TextStyle label = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.5, // 18px line height
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  /// Label Medium - Inter 14px SemiBold
  /// Usage: Form labels, input labels
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.43, // 20px line height
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // SPECIAL STYLES
  // ============================================================================

  /// Caption - Inter 12px Regular
  /// Usage: Hints, helper text
  static const TextStyle caption = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 1.5, // 18px line height
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  /// Overline - Inter 10px SemiBold Uppercase
  /// Usage: Tiny labels, tags
  static const TextStyle overline = TextStyle(
    fontFamily: _interFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.6, // 16px line height
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // COLOR VARIATIONS
  // ============================================================================

  /// Apply white color to any text style
  static TextStyle white(TextStyle style) =>
      style.copyWith(color: Colors.white);

  /// Apply primary color to any text style
  static TextStyle primary(TextStyle style) =>
      style.copyWith(color: AppColors.primary);

  /// Apply secondary color to any text style
  static TextStyle secondary(TextStyle style) =>
      style.copyWith(color: AppColors.textSecondary);

  /// Apply success color to any text style
  static TextStyle success(TextStyle style) =>
      style.copyWith(color: AppColors.success);

  /// Apply warning color to any text style
  static TextStyle warning(TextStyle style) =>
      style.copyWith(color: AppColors.warning);

  /// Apply danger color to any text style
  static TextStyle danger(TextStyle style) =>
      style.copyWith(color: AppColors.danger);

  /// Apply accent color to any text style
  static TextStyle accent(TextStyle style) =>
      style.copyWith(color: AppColors.accent);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Create a custom text style based on existing style
  static TextStyle custom({
    required TextStyle base,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return base.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
