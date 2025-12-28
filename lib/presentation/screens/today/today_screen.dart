import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/habit/habit_bloc.dart';
import '../../blocs/habit/habit_event.dart';
import '../../blocs/habit/habit_state.dart';
import '../../blocs/xp/xp_bloc.dart';
import '../../blocs/xp/xp_event.dart';
import '../../blocs/xp/xp_state.dart';
import '../../widgets/xp/xp_progress_bar.dart';
import '../../widgets/animations/habit_completion_animation.dart';
import '../../widgets/animations/xp_award_animation.dart';
import 'widgets/progress_card.dart';
import 'widgets/add_habit_button.dart';

/// Today Screen
/// Main screen showing today's habits and progress
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load today's habits
    context.read<HabitBloc>().add(
      const HabitsLoadRequested(
        userId: 'current_user_id', // TODOs: Get from auth
        activeOnly: true,
      ),
    );

    // Load XP stats
    context.read<XpBloc>().add(
      const XpStatsRequested('current_user_id'), // TODOs: Get from auth
    );
  }

  void _completeHabit(String habitId) {
    context.read<HabitBloc>().add(
      HabitCompleteRequested(
        userId: 'current_user_id', // TODOs: Get from auth
        habitId: habitId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Today',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // XP Progress Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<XpBloc, XpState>(
                  builder: (context, state) {
                    if (state is XpStatsLoaded) {
                      return XpProgressBar(
                        currentLevel: state.currentLevel,
                        totalXp: state.totalXp,
                        progressToNextLevel: state.progressToNextLevel,
                        xpToNextLevel: state.xpToNextLevel,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            // Progress Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ProgressCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Today\'s Habits',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    AddHabitButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/habit/add');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Habits List
            BlocConsumer<HabitBloc, HabitState>(
              listener: (context, state) {
                if (state is HabitCompleted) {
                  // Show completion animation
                  showHabitCompletionAnimation(context);

                  // Show XP award
                  Future.delayed(const Duration(milliseconds: 800), () {
                    showXpAwardAnimation(
                      context,
                      xpAmount: state.xpEarned,
                      hasBonus: state.hadBonus,
                    );
                  });

                  // Reload habits
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    _loadData();
                  });
                }
              },
              builder: (context, state) {
                if (state is HabitLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is HabitsLoaded) {
                  if (state.habits.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco,
                              size: 80,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first habit to start growing!',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/habit/add');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Habit'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final habit = state.habits[index];
                        return HabitCard(
                          habit: habit,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/habit/detail', arguments: habit);
                          },
                          onComplete: () => _completeHabit(habit.id),
                        );
                      }, childCount: state.habits.length),
                    ),
                  );
                } else if (state is HabitError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
