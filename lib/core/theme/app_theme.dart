import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habbit_island/core/theme/app_colors.dart';
import 'package:habbit_island/core/theme/app_dimensions.dart';
import 'package:habbit_island/core/theme/app_typography.dart';

/// Habit Island Theme Configuration
/// This class provides complete Material Design theme configurations
/// for the entire application, integrating colors, typography, and dimensions.
class AppTheme {
  AppTheme._(); // Private constructor

  // ============================================================================
  // LIGHT THEME (Primary theme for MVP)
  // ============================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        error: AppColors.danger,
        surface: AppColors.background,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
        outline: AppColors.border,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // Typography
      textTheme: _buildTextTheme(),

      // App Bar Theme
      appBarTheme: _buildAppBarTheme(),

      // Button Themes
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      iconButtonTheme: _buildIconButtonTheme(),

      // Card Theme
      cardTheme: _buildCardTheme(),

      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),

      // Divider Theme
      dividerTheme: _buildDividerTheme(),

      // Dialog Theme
      dialogTheme: _buildDialogTheme(),

      // Bottom Sheet Theme
      bottomSheetTheme: _buildBottomSheetTheme(),

      // Chip Theme
      chipTheme: _buildChipTheme(),

      // Progress Indicator Theme
      progressIndicatorTheme: _buildProgressIndicatorTheme(),

      // Switch Theme
      switchTheme: _buildSwitchTheme(),

      // Checkbox Theme
      checkboxTheme: _buildCheckboxTheme(),

      // Radio Theme
      radioTheme: _buildRadioTheme(),

      // Slider Theme
      sliderTheme: _buildSliderTheme(),

      // Floating Action Button Theme
      floatingActionButtonTheme: _buildFabTheme(),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppDimensions.iconSizeM,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: AppDimensions.iconSizeM,
      ),

      // Tooltip Theme
      tooltipTheme: _buildTooltipTheme(),

      // Snackbar Theme
      snackBarTheme: _buildSnackBarTheme(),

      // Tab Bar Theme
      tabBarTheme: _buildTabBarTheme(),
    );
  }

  // ============================================================================
  // DARK THEME (Post-MVP)
  // ============================================================================

  static ThemeData get darkTheme {
    // For MVP, return light theme
    // Post-MVP: implement true dark mode with adjusted colors
    return lightTheme;
  }

  // ============================================================================
  // TEXT THEME
  // ============================================================================

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display styles
      displayLarge: AppTypography.display,
      displayMedium: AppTypography.h1,
      displaySmall: AppTypography.h2,

      // Headline styles
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,

      // Title styles
      titleLarge: AppTypography.h2,
      titleMedium: AppTypography.h3,
      titleSmall: AppTypography.labelMedium,

      // Body styles
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.bodySmall,

      // Label styles
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.label,
    );
  }

  // ============================================================================
  // APP BAR THEME
  // ============================================================================

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: AppTypography.h2,
      toolbarHeight: AppDimensions.appBarHeight,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppDimensions.iconSizeM,
      ),
    );
  }

  // ============================================================================
  // BUTTON THEMES
  // ============================================================================

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withAlpha(102),
        disabledForegroundColor: Colors.white.withAlpha(152),
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        padding: AppDimensions.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: AppTypography.button,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withAlpha(102),
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        padding: AppDimensions.buttonPadding,
        side: const BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withAlpha(102),
        minimumSize: const Size(0, AppDimensions.buttonGhostHeight),
        padding: AppDimensions.buttonGhostPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    );
  }

  static IconButtonThemeData _buildIconButtonTheme() {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(
          AppDimensions.buttonIconSize,
          AppDimensions.buttonIconSize,
        ),
        padding: const EdgeInsets.all(AppDimensions.buttonIconPadding),
        iconSize: AppDimensions.iconSizeM,
      ),
    );
  }

  // ============================================================================
  // CARD THEME
  // ============================================================================

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: AppColors.cardBackground,
      elevation: AppDimensions.cardElevation,
      shadowColor: Colors.black.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusL),
      margin: AppDimensions.cardMargin,
      clipBehavior: Clip.antiAlias,
    );
  }

  // ============================================================================
  // INPUT DECORATION THEME
  // ============================================================================

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: AppDimensions.inputPaddingAll,

      // Border styles
      border: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusM,
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.inputBorderWidthDefault,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusM,
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppDimensions.inputBorderWidthDefault,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusM,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppDimensions.inputBorderWidthFocus,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusM,
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: AppDimensions.inputBorderWidthError,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusM,
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: AppDimensions.inputBorderWidthError,
        ),
      ),

      // Text styles
      labelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      floatingLabelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.primary,
      ),
      hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
      errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.danger),

      // Icons
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    );
  }

  // ============================================================================
  // BOTTOM NAVIGATION BAR THEME
  // ============================================================================

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme() {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.caption,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  // ============================================================================
  // DIVIDER THEME
  // ============================================================================

  static DividerThemeData _buildDividerTheme() {
    return const DividerThemeData(
      color: AppColors.divider,
      thickness: AppDimensions.dividerThickness,
      space: AppDimensions.spacingL,
    );
  }

  // ============================================================================
  // DIALOG THEME
  // ============================================================================

  static DialogThemeData _buildDialogTheme() {
    return DialogThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusL),
      titleTextStyle: AppTypography.h2,
      contentTextStyle: AppTypography.body,
    );
  }

  // ============================================================================
  // BOTTOM SHEET THEME
  // ============================================================================

  static BottomSheetThemeData _buildBottomSheetTheme() {
    return BottomSheetThemeData(
      backgroundColor: AppColors.cardBackground,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusTopXl,
      ),
      clipBehavior: Clip.antiAlias,
      modalBackgroundColor: AppColors.cardBackground,
      modalElevation: 8,
    );
  }

  // ============================================================================
  // CHIP THEME
  // ============================================================================

  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: AppColors.primaryLight,
      deleteIconColor: AppColors.textSecondary,
      disabledColor: AppColors.border,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      labelStyle: AppTypography.bodySmall,
      secondaryLabelStyle: AppTypography.bodySmall,
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusS),
    );
  }

  // ============================================================================
  // PROGRESS INDICATOR THEME
  // ============================================================================

  static ProgressIndicatorThemeData _buildProgressIndicatorTheme() {
    return const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
      linearMinHeight: AppDimensions.progressBarHeight,
    );
  }

  // ============================================================================
  // SWITCH THEME
  // ============================================================================

  static SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.border;
      }),
    );
  }

  // ============================================================================
  // CHECKBOX THEME
  // ============================================================================

  static CheckboxThemeData _buildCheckboxTheme() {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.border, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }

  // ============================================================================
  // RADIO THEME
  // ============================================================================

  static RadioThemeData _buildRadioTheme() {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.border;
      }),
    );
  }

  // ============================================================================
  // SLIDER THEME
  // ============================================================================

  static SliderThemeData _buildSliderTheme() {
    return const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primary,
      overlayColor: Color(0x1F6B9AC4), // primary with 12% opacity
      trackHeight: 4,
    );
  }

  // ============================================================================
  // FLOATING ACTION BUTTON THEME
  // ============================================================================

  static FloatingActionButtonThemeData _buildFabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: CircleBorder(),
    );
  }

  // ============================================================================
  // TOOLTIP THEME
  // ============================================================================

  static TooltipThemeData _buildTooltipTheme() {
    return TooltipThemeData(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      margin: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withAlpha(229),
        borderRadius: AppDimensions.borderRadiusS,
      ),
      textStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
    );
  }

  // ============================================================================
  // SNACKBAR THEME
  // ============================================================================

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.body.copyWith(color: Colors.white),
      actionTextColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusM),
      elevation: 6,
    );
  }

  // ============================================================================
  // TAB BAR THEME
  // ============================================================================

  static TabBarThemeData _buildTabBarTheme() {
    return TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTypography.labelMedium,
      unselectedLabelStyle: AppTypography.labelMedium,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
