import 'package:flutter/material.dart';
import 'widgets/calendar_heatmap.dart';
import 'widgets/overall_card.dart';
import 'widgets/weekly_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Statistics'),
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
                const OverallCard(),
                const SizedBox(height: 16),
                const WeeklyCard(),
                const SizedBox(height: 16),
                const CalendarHeatmap(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
