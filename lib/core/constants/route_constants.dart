/// Habit Island Route Constants
/// Centralized route name management for the application.
/// This file defines all navigation routes used throughout the app
/// following a hierarchical naming convention.
library;

class RouteConstants {
  RouteConstants._(); // Private constructor

  // ============================================================================
  // AUTHENTICATION & ONBOARDING
  // ============================================================================

  /// Splash screen (initial loading)
  static const String splash = '/';

  /// Onboarding flow (5 screens)
  static const String onboarding = '/onboarding';

  /// Login screen
  static const String login = '/login';

  /// Sign up screen
  static const String signup = '/signup';

  /// Password reset screen
  static const String forgotPassword = '/forgot-password';

  // ============================================================================
  // MAIN NAVIGATION (Bottom Nav)
  // ============================================================================

  /// Home screen with island view (main tab)
  static const String home = '/home';

  /// Today view screen (habits list tab)
  static const String today = '/today';

  /// Stats dashboard screen
  static const String stats = '/stats';

  // ============================================================================
  // HABIT MANAGEMENT
  // ============================================================================

  /// Add new habit screen
  static const String addHabit = '/habit/add';

  /// Edit existing habit screen
  /// Route params: habitId
  static const String editHabit = '/habit/edit';

  /// Habit detail modal/screen
  /// Route params: habitId
  static const String habitDetail = '/habit/detail';

  /// Habit history calendar view
  /// Route params: habitId
  static const String habitHistory = '/habit/history';

  // ============================================================================
  // ISLAND & GAME
  // ============================================================================

  /// Island theme selection (premium feature)
  static const String islandThemes = '/island/themes';

  /// Island zone information
  /// Route params: zoneId
  static const String zoneInfo = '/island/zone';

  /// Achievement/celebration modal
  /// Route params: achievementType
  static const String achievement = '/achievement';

  /// XP milestone celebration
  /// Route params: level
  static const String levelUp = '/level-up';

  // ============================================================================
  // SETTINGS & ACCOUNT
  // ============================================================================

  /// Main settings screen
  static const String settings = '/settings';

  /// Account settings
  static const String accountSettings = '/settings/account';

  /// Notification preferences
  static const String notificationSettings = '/settings/notifications';

  /// App preferences (theme, language, etc.)
  static const String preferences = '/settings/preferences';

  /// Data management (backup, export, delete)
  static const String dataSettings = '/settings/data';

  /// About & legal information
  static const String about = '/settings/about';

  // ============================================================================
  // PREMIUM & MONETIZATION
  // ============================================================================

  /// Premium subscription paywall
  static const String premium = '/premium';

  /// Premium features overview
  static const String premiumFeatures = '/premium/features';

  /// Subscription management
  static const String subscriptionManage = '/premium/manage';

  /// Restore purchases screen
  static const String restorePurchases = '/premium/restore';

  // ============================================================================
  // HELP & SUPPORT
  // ============================================================================

  /// Help center/FAQ
  static const String help = '/help';

  /// Contact support
  static const String contactSupport = '/help/contact';

  /// App tutorial (re-watch onboarding)
  static const String tutorial = '/help/tutorial';

  // ============================================================================
  // WEB VIEWS & EXTERNAL
  // ============================================================================

  /// Privacy policy web view
  static const String privacyPolicy = '/legal/privacy';

  /// Terms of service web view
  static const String termsOfService = '/legal/terms';

  // ============================================================================
  // ROUTE PARAMETER KEYS
  // ============================================================================

  /// Parameter key for habit ID
  static const String paramHabitId = 'habitId';

  /// Parameter key for zone ID
  static const String paramZoneId = 'zoneId';

  /// Parameter key for achievement type
  static const String paramAchievementType = 'achievementType';

  /// Parameter key for level number
  static const String paramLevel = 'level';

  /// Parameter key for onboarding page index
  static const String paramPageIndex = 'pageIndex';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Build route with parameters
  static String withParams(String route, Map<String, String> params) {
    final uri = Uri(path: route, queryParameters: params);
    return uri.toString();
  }

  /// Build habit detail route with ID
  static String habitDetailRoute(String habitId) {
    return withParams(habitDetail, {paramHabitId: habitId});
  }

  /// Build edit habit route with ID
  static String editHabitRoute(String habitId) {
    return withParams(editHabit, {paramHabitId: habitId});
  }

  /// Build habit history route with ID
  static String habitHistoryRoute(String habitId) {
    return withParams(habitHistory, {paramHabitId: habitId});
  }

  /// Build zone info route with ID
  static String zoneInfoRoute(String zoneId) {
    return withParams(zoneInfo, {paramZoneId: zoneId});
  }

  /// Build achievement route with type
  static String achievementRoute(String achievementType) {
    return withParams(achievement, {paramAchievementType: achievementType});
  }

  /// Build level up route with level number
  static String levelUpRoute(int level) {
    return withParams(levelUp, {paramLevel: level.toString()});
  }

  // ============================================================================
  // ROUTE GROUPS (for route guards/middleware)
  // ============================================================================

  /// Routes that require authentication
  static const List<String> authenticatedRoutes = [
    home,
    today,
    stats,
    addHabit,
    editHabit,
    habitDetail,
    settings,
    premium,
  ];

  /// Routes accessible without authentication
  static const List<String> publicRoutes = [
    splash,
    onboarding,
    login,
    signup,
    forgotPassword,
  ];

  /// Routes that require premium subscription
  static const List<String> premiumRoutes = [islandThemes];

  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    return authenticatedRoutes.any((r) => route.startsWith(r));
  }

  /// Check if route requires premium
  static bool requiresPremium(String route) {
    return premiumRoutes.any((r) => route.startsWith(r));
  }

  /// Check if route is public
  static bool isPublic(String route) {
    return publicRoutes.any((r) => route.startsWith(r));
  }
}
