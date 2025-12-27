import 'package:flutter/material.dart';
import 'package:habbit_island/domain/entities/habit.dart';
import '../../widgets/habit/streak_indicator.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(habit.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StreakIndicator(
                  currentStreak: habit.currentStreak,
                  longestStreak: habit.longestStreak,
                ),
                const SizedBox(height: 24),
                _buildStatsCard(context),
                const SizedBox(height: 24),
                _buildGrowthCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(context, 'Total', habit.totalCompletions.toString()),
                _statItem(context, 'Current', habit.currentStreak.toString()),
                _statItem(context, 'Best', habit.longestStreak.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Stage: ${habit.growthStage.toString().split('.').last}'),
            Text('Level: ${habit.growthLevel}'),
            LinearProgressIndicator(value: habit.growthProgress),
          ],
        ),
      ),
    );
  }

  Widget _statItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
