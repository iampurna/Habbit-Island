import 'package:flutter/material.dart';

/// Habit Island Dimension System
/// Defines all spacing, sizing, and layout dimensions used throughout the app.
/// Provides consistent spacing scale and component measurements.
class AppDimensions {
  AppDimensions._(); // Private constructor

  // ============================================================================
  // SPACING SCALE (8pt grid system)
  // ============================================================================

  /// Extra small spacing - 4px
  static const double spacingXs = 4.0;

  /// Small spacing - 8px
  static const double spacingS = 8.0;

  /// Medium spacing - 12px
  static const double spacingM = 12.0;

  /// Large spacing - 16px
  static const double spacingL = 16.0;

  /// Extra large spacing - 24px
  static const double spacingXl = 24.0;

  /// 2X large spacing - 32px
  static const double spacing2Xl = 32.0;

  /// 3X large spacing - 40px
  static const double spacing3Xl = 40.0;

  /// 4X large spacing - 48px
  static const double spacing4Xl = 48.0;

  /// 5X large spacing - 64px
  static const double spacing5Xl = 64.0;

  // ============================================================================
  // BUTTON DIMENSIONS
  // ============================================================================

  // Primary & Secondary Buttons
  static const double buttonHeight = 48.0;
  static const double buttonPaddingH = 24.0;
  static const double buttonRadius = 12.0;

  // Ghost Button
  static const double buttonGhostHeight = 40.0;
  static const double buttonGhostPaddingH = 16.0;
  static const double buttonGhostRadius = 8.0;

  // Icon Button
  static const double buttonIconSize = 44.0;
  static const double buttonIconPadding = 10.0;
  static const double buttonIconRadius = 22.0; // Circle
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Edge Insets
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: buttonPaddingH,
    vertical: 12.0,
  );

  static const EdgeInsets buttonGhostPadding = EdgeInsets.symmetric(
    horizontal: buttonGhostPaddingH,
    vertical: 8.0,
  );

  // ============================================================================
  // CARD DIMENSIONS
  // ============================================================================

  static const double cardRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double cardBorderWidth = 1.0;

  /// Card edge insets
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);

  /// Card margin (from screen edge)
  static const EdgeInsets cardMargin = EdgeInsets.all(spacingL);

  /// Card elevation
  static const double cardElevation = 2.0;

  // ============================================================================
  // INPUT FIELD DIMENSIONS
  // ============================================================================

  static const double inputHeight = 48.0;
  static const double inputRadius = 12.0;
  static const double inputPadding = 16.0;
  static const double inputBorderWidthDefault = 1.0;
  static const double inputBorderWidthFocus = 2.0;
  static const double inputBorderWidthError = 2.0;

  /// Input field padding
  static const EdgeInsets inputPaddingAll = EdgeInsets.symmetric(
    horizontal: inputPadding,
    vertical: 12.0,
  );

  // ============================================================================
  // SCREEN LAYOUT DIMENSIONS
  // ============================================================================

  /// Standard screen horizontal padding
  static const double screenPaddingH = 24.0;

  /// Screen padding from top (below app bar)
  static const double screenPaddingTop = 16.0;

  /// Screen padding from bottom (above navigation)
  static const double screenPaddingBottom = 16.0;

  /// Screen edge insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingH,
    vertical: screenPaddingTop,
  );

  /// Modal/Bottom sheet padding
  static const EdgeInsets modalPadding = EdgeInsets.all(24.0);

  // ============================================================================
  // NAVIGATION DIMENSIONS
  // ============================================================================

  /// Top app bar height
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 64.0;
  static const double bottomNavElevation = 8.0;

  /// Bottom navigation icon size
  static const double bottomNavIconSize = 24.0;

  // ============================================================================
  // TAP TARGET DIMENSIONS (Accessibility)
  // ============================================================================

  /// Minimum tap target size (WCAG AA)
  static const double minTapTarget = 44.0;

  /// Comfortable tap target size
  static const double comfortableTapTarget = 48.0;

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  /// Extra small icon - 16px
  static const double iconSizeXs = 16.0;

  /// Small icon - 20px
  static const double iconSizeS = 20.0;

  /// Medium icon - 24px (default)
  static const double iconSizeM = 24.0;

  /// Large icon - 32px
  static const double iconSizeL = 32.0;

  /// Extra large icon - 48px
  static const double iconSizeXl = 48.0;

  /// 2X large icon - 64px
  static const double iconSize2Xl = 64.0;

  /// 3X large icon - 80px
  static const double iconSize3Xl = 80.0;

  // ============================================================================
  // HABIT CARD DIMENSIONS (from Today View spec)
  // ============================================================================

  static const double habitCardHeight = 72.0;
  static const double habitCardCheckboxSize = 24.0;
  static const double habitCardCompletedBorderWidth = 4.0;

  /// Add habit button height
  static const double addHabitButtonHeight = 56.0;

  // ============================================================================
  // BORDER RADIUS VARIANTS
  // ============================================================================

  /// Small radius - 8px
  static const double radiusS = 8.0;

  /// Medium radius - 12px
  static const double radiusM = 12.0;

  /// Large radius - 16px
  static const double radiusL = 16.0;

  /// Extra large radius - 24px (for modals)
  static const double radiusXl = 24.0;

  /// Circle radius - 50%
  static const double radiusCircle = 100.0;

  /// Border radius objects
  static const BorderRadius borderRadiusS = BorderRadius.all(
    Radius.circular(radiusS),
  );
  static const BorderRadius borderRadiusM = BorderRadius.all(
    Radius.circular(radiusM),
  );
  static const BorderRadius borderRadiusL = BorderRadius.all(
    Radius.circular(radiusL),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );

  /// Top-only radius (for bottom sheets)
  static const BorderRadius borderRadiusTopL = BorderRadius.only(
    topLeft: Radius.circular(radiusL),
    topRight: Radius.circular(radiusL),
  );

  static const BorderRadius borderRadiusTopXl = BorderRadius.only(
    topLeft: Radius.circular(radiusXl),
    topRight: Radius.circular(radiusXl),
  );

  // ============================================================================
  // ONBOARDING DIMENSIONS
  // ============================================================================

  /// Onboarding illustration size
  static const double onboardingIllustrationWidth = 280.0;
  static const double onboardingIllustrationHeight = 200.0;

  /// Progress dots
  static const double onboardingDotSize = 8.0;
  static const double onboardingDotGap = 12.0;

  // ============================================================================
  // MODAL DIMENSIONS
  // ============================================================================

  /// Bottom sheet initial height (% of screen)
  static const double bottomSheetHeightRatio = 0.7;

  /// Bottom sheet max height (% of screen)
  static const double bottomSheetMaxHeightRatio = 0.9;

  /// Drag handle dimensions
  static const double dragHandleWidth = 40.0;
  static const double dragHandleHeight = 4.0;

  // ============================================================================
  // STATS DASHBOARD DIMENSIONS
  // ============================================================================

  /// Calendar heatmap cell size
  static const double heatmapCellSize = 12.0;

  /// Progress bar height
  static const double progressBarHeight = 8.0;

  /// Habit breakdown row height
  static const double habitBreakdownRowHeight = 48.0;

  // ============================================================================
  // SETTINGS DIMENSIONS
  // ============================================================================

  /// Settings row height
  static const double settingsRowHeight = 56.0;

  /// Settings icon size
  static const double settingsIconSize = 24.0;

  // ============================================================================
  // ISLAND VIEW DIMENSIONS
  // ============================================================================

  /// Island canvas zoom limits
  static const double islandZoomMin = 0.5;
  static const double islandZoomMax = 2.0;

  /// Sprite base sizes
  static const double spriteLevel1Size = 64.0;
  static const double spriteLevel2Size = 96.0;
  static const double spriteLevel3Size = 128.0;

  // ============================================================================
  // PREMIUM PAYWALL DIMENSIONS
  // ============================================================================

  /// Pricing card dimensions
  static const double pricingCardHeight = 72.0;
  static const double benefitRowHeight = 72.0;
  static const double benefitIconSize = 32.0;

  // ============================================================================
  // DIVIDER DIMENSIONS
  // ============================================================================

  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;

  // ============================================================================
  // ANIMATION DURATIONS (milliseconds)
  // ============================================================================

  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  /// Duration objects
  static const Duration durationFast = Duration(milliseconds: animationFast);
  static const Duration durationNormal = Duration(
    milliseconds: animationNormal,
  );
  static const Duration durationSlow = Duration(milliseconds: animationSlow);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get responsive padding based on screen width
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      // Tablet
      return const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);
    }
    return screenPadding;
  }

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get bottom navigation safe area height
  static double bottomNavSafeHeight(BuildContext context) {
    return bottomNavHeight + MediaQuery.of(context).padding.bottom;
  }
}
