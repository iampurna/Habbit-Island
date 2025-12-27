import 'package:flutter/material.dart';
import 'widgets/onboarding_page.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/ghost_button.dart';

/// Onboarding Screen
/// Introduction to app features with page carousel
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Build Better Habits',
      'description':
          'Track your daily habits and watch your personal island grow with every completion',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
    },
    {
      'title': 'Earn XP & Level Up',
      'description':
          'Complete habits to earn experience points, level up, and unlock new island zones',
      'icon': Icons.stars,
      'color': Colors.amber,
    },
    {
      'title': 'Never Break the Chain',
      'description':
          'Build streaks and watch your habits grow from seeds to mighty forests',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
    },
    {
      'title': 'Track Your Progress',
      'description':
          'Beautiful visualizations show your journey and celebrate every milestone',
      'icon': Icons.insights,
      'color': Colors.blue,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/auth/login');
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GhostButton(text: 'Skip', onPressed: _skip),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    title: page['title'],
                    description: page['description'],
                    icon: page['icon'],
                    iconColor: page['color'],
                  );
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                text: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _nextPage,
                icon: Icons.arrow_forward,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
