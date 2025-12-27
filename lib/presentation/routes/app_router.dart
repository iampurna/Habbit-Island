/// App Router
/// Central routing configuration with named routes
class AppRouter {
  // Route Names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main App Routes
  static const String today = '/today';
  static const String home = '/home';
  static const String stats = '/stats';
  static const String settings = '/settings';

  // Habit Routes
  static const String habitAdd = '/habit/add';
  static const String habitEdit = '/habit/edit';
  static const String habitDetail = '/habit/detail';
  static const String habitHistory = '/habit/history';

  // Island Routes
  static const String islandView = '/island';
  static const String zoneDetail = '/island/zone';

  // Premium Routes
  static const String premium = '/premium';
  static const String premiumSuccess = '/premium/success';
  static const String premiumRestore = '/premium/restore';

  // Profile Routes
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String achievements = '/achievements';

  // Settings Routes
  static const String notifications = '/settings/notifications';
  static const String theme = '/settings/theme';
  static const String language = '/settings/language';
  static const String about = '/settings/about';
  static const String help = '/settings/help';
  static const String privacy = '/settings/privacy';
  static const String terms = '/settings/terms';

  // Debug/Dev Routes (remove in production)
  static const String debug = '/debug';
  static const String testAnimations = '/debug/animations';
  static const String testWidgets = '/debug/widgets';

  /// Check if route requires authentication
  static bool requiresAuth(String? routeName) {
    if (routeName == null) return false;

    final publicRoutes = [splash, onboarding, login, signup, forgotPassword];

    return !publicRoutes.contains(routeName);
  }

  /// Get initial route based on auth state
  static String getInitialRoute({
    required bool isFirstLaunch,
    required bool isAuthenticated,
  }) {
    if (isFirstLaunch) {
      return onboarding;
    }

    if (!isAuthenticated) {
      return login;
    }

    return today;
  }

  /// Route transition duration
  static const Duration transitionDuration = Duration(milliseconds: 300);

  /// Route names for analytics tracking
  static String getAnalyticsName(String route) {
    return route.replaceAll('/', '_').substring(1);
  }

  /// All route names for navigation testing
  static List<String> get allRoutes => [
    splash,
    onboarding,
    login,
    signup,
    forgotPassword,
    today,
    home,
    stats,
    settings,
    habitAdd,
    habitEdit,
    habitDetail,
    habitHistory,
    islandView,
    zoneDetail,
    premium,
    premiumSuccess,
    premiumRestore,
    profile,
    profileEdit,
    achievements,
    notifications,
    theme,
    language,
    about,
    help,
    privacy,
    terms,
  ];

  /// Route titles for app bar
  static String getRouteTitle(String route) {
    final titles = {
      splash: 'Habit Island',
      onboarding: 'Welcome',
      login: 'Sign In',
      signup: 'Create Account',
      forgotPassword: 'Reset Password',
      today: 'Today',
      home: 'Island',
      stats: 'Statistics',
      settings: 'Settings',
      habitAdd: 'Create Habit',
      habitEdit: 'Edit Habit',
      habitDetail: 'Habit Details',
      habitHistory: 'History',
      islandView: 'My Island',
      zoneDetail: 'Zone Details',
      premium: 'Go Premium',
      premiumSuccess: 'Welcome to Premium!',
      premiumRestore: 'Restore Purchase',
      profile: 'Profile',
      profileEdit: 'Edit Profile',
      achievements: 'Achievements',
      notifications: 'Notifications',
      theme: 'Theme',
      language: 'Language',
      about: 'About',
      help: 'Help & Support',
      privacy: 'Privacy Policy',
      terms: 'Terms of Service',
    };

    return titles[route] ?? 'Habit Island';
  }
}
