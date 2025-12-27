import 'package:flutter/material.dart';
import 'package:habbit_island/domain/entities/habit.dart';

// Screens
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/today/today_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/habit/add_habit_screen.dart';
import '../screens/habit/edit_habit_screen.dart';
import '../screens/habit/habit_detail_screen.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/settings/settings_screen.dart';

// Animations

// Entities

// Router
import 'app_router.dart';

/// Route Generator
/// Handles route generation with custom transitions and argument parsing
class RouteGenerator {
  /// Generate route with appropriate screen and transition
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Log navigation for analytics (in production app)
    // AnalyticsService.logScreenView(settings.name);

    switch (settings.name) {
      // ========================================
      // SPLASH & ONBOARDING
      // ========================================
      case AppRouter.splash:
        return _buildRoute(
          const SplashScreen(),
          settings: settings,
          transition: PageTransitionType.fade,
        );

      case AppRouter.onboarding:
        return _buildRoute(
          const OnboardingScreen(),
          settings: settings,
          transition: PageTransitionType.fade,
        );

      // ========================================
      // AUTHENTICATION
      // ========================================
      case AppRouter.login:
        return _buildRoute(
          const LoginScreen(),
          settings: settings,
          transition: PageTransitionType.slideRight,
        );

      case AppRouter.signup:
        return _buildRoute(
          const SignUpScreen(),
          settings: settings,
          transition: PageTransitionType.slideUp,
        );

      // ========================================
      // MAIN SCREENS
      // ========================================
      case AppRouter.today:
        return _buildRoute(
          const TodayScreen(),
          settings: settings,
          transition: PageTransitionType.fade,
        );

      case AppRouter.home:
        return _buildRoute(
          const HomeScreen(),
          settings: settings,
          transition: PageTransitionType.fade,
        );

      case AppRouter.stats:
        return _buildRoute(
          const StatsScreen(),
          settings: settings,
          transition: PageTransitionType.slideRight,
        );

      case AppRouter.settings:
        return _buildRoute(
          const SettingsScreen(),
          settings: settings,
          transition: PageTransitionType.slideRight,
        );

      // ========================================
      // HABIT SCREENS
      // ========================================
      case AppRouter.habitAdd:
        return _buildRoute(
          const AddHabitScreen(),
          settings: settings,
          transition: PageTransitionType.slideUp,
          fullscreenDialog: true,
        );

      case AppRouter.habitEdit:
        final habit = settings.arguments as Habit?;
        if (habit == null) {
          return _buildErrorRoute(settings, 'Habit not found');
        }
        return _buildRoute(
          EditHabitScreen(habit: habit),
          settings: settings,
          transition: PageTransitionType.slideUp,
          fullscreenDialog: true,
        );

      case AppRouter.habitDetail:
        final habit = settings.arguments as Habit?;
        if (habit == null) {
          return _buildErrorRoute(settings, 'Habit not found');
        }
        return _buildRoute(
          HabitDetailScreen(habit: habit),
          settings: settings,
          transition: PageTransitionType.slideRight,
        );

      // ========================================
      // PREMIUM
      // ========================================
      case AppRouter.premium:
        return _buildRoute(
          const PremiumScreen(),
          settings: settings,
          transition: PageTransitionType.scale,
        );

      // ========================================
      // ERROR/DEFAULT
      // ========================================
      default:
        return _buildErrorRoute(settings, 'Route not found: ${settings.name}');
    }
  }

  /// Build route with custom transition
  static Route<dynamic> _buildRoute(
    Widget screen, {
    required RouteSettings settings,
    PageTransitionType transition = PageTransitionType.slideRight,
    bool fullscreenDialog = false,
  }) {
    switch (transition) {
      case PageTransitionType.fade:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppRouter.transitionDuration,
          fullscreenDialog: fullscreenDialog,
        );

      case PageTransitionType.slideRight:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: AppRouter.transitionDuration,
          fullscreenDialog: fullscreenDialog,
        );

      case PageTransitionType.slideUp:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: AppRouter.transitionDuration,
          fullscreenDialog: fullscreenDialog,
        );

      case PageTransitionType.scale:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final scaleTween = Tween(
              begin: 0.8,
              end: 1.0,
            ).chain(CurveTween(curve: curve));
            final fadeTween = Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          fullscreenDialog: fullscreenDialog,
        );

      case PageTransitionType.rotation:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final rotationTween = Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: curve));
            final fadeTween = Tween(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: RotationTransition(
                turns: animation.drive(rotationTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
          fullscreenDialog: fullscreenDialog,
        );
    }
  }

  /// Build error route
  static Route<dynamic> _buildErrorRoute(
    RouteSettings settings,
    String message,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Oops!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.today,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate with custom transition
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    PageTransitionType transition = PageTransitionType.slideRight,
  }) {
    return Navigator.of(context).push<T>(
      _buildRoute(
        _getScreenForRoute(routeName, arguments),
        settings: RouteSettings(name: routeName, arguments: arguments),
        transition: transition,
      ),
    );
  }

  /// Replace current route
  static Future<T?> replaceTo<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
    PageTransitionType transition = PageTransitionType.slideRight,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      _buildRoute(
        _getScreenForRoute(routeName, arguments),
        settings: RouteSettings(name: routeName, arguments: arguments),
        transition: transition,
      ),
      result: result,
    );
  }

  /// Clear stack and navigate
  static Future<T?> navigateAndClearStack<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    PageTransitionType transition = PageTransitionType.fade,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _buildRoute(
        _getScreenForRoute(routeName, arguments),
        settings: RouteSettings(name: routeName, arguments: arguments),
        transition: transition,
      ),
      (route) => false,
    );
  }

  /// Get screen widget for route name
  static Widget _getScreenForRoute(String routeName, Object? arguments) {
    // This is a helper method for programmatic navigation
    // Implement based on your routing needs
    switch (routeName) {
      case AppRouter.today:
        return const TodayScreen();
      case AppRouter.home:
        return const HomeScreen();
      case AppRouter.stats:
        return const StatsScreen();
      case AppRouter.settings:
        return const SettingsScreen();
      default:
        return const Scaffold(
          body: Center(child: Text('Screen not implemented')),
        );
    }
  }
}

/// Page Transition Types
enum PageTransitionType { fade, slideRight, slideUp, scale, rotation }
