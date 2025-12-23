import 'package:flutter/material.dart';
import '../../../domain/entities/habit.dart';

/// Habit Card
/// Displays habit information with completion status and streak
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool showCompleteButton;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
    this.showCompleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = habit.isCompletedToday;

    return BaseCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      border: isCompleted
          ? Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 2,
            )
          : null,
      backgroundColor: isCompleted
          ? theme.colorScheme.primary.withOpacity(0.05)
          : null,
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getCategoryColor(habit.category, theme).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(habit.category),
              color: _getCategoryColor(habit.category, theme),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Habit Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  habit.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? theme.colorScheme.onSurface.withOpacity(0.5)
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Streak & Stats
                Row(
                  children: [
                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: habit.currentStreak > 0
                            ? Colors.orange.withOpacity(0.15)
                            : theme.colorScheme.outline.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: habit.currentStreak > 0
                                ? Colors.orange
                                : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: habit.currentStreak > 0
                                  ? Colors.orange
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.4,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Growth Stage
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getGrowthStageIcon(habit.growthStage),
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getGrowthStageName(habit.growthStage),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Complete Button or Checkmark
          if (showCompleteButton)
            if (isCompleted)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              )
            else
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onComplete,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      size: 28,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Color _getCategoryColor(HabitCategory category, ThemeData theme) {
    switch (category) {
      case HabitCategory.water:
        return Colors.blue;
      case HabitCategory.exercise:
        return Colors.red;
      case HabitCategory.mindfulness:
        return Colors.purple;
      case HabitCategory.nutrition:
        return Colors.green;
      case HabitCategory.sleep:
        return Colors.indigo;
      case HabitCategory.productivity:
        return Colors.orange;
      case HabitCategory.learning:
        return Colors.teal;
      case HabitCategory.social:
        return Colors.pink;
      case HabitCategory.creative:
        return Colors.amber;
      case HabitCategory.custom:
        return theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.water:
        return Icons.water_drop;
      case HabitCategory.exercise:
        return Icons.fitness_center;
      case HabitCategory.mindfulness:
        return Icons.spa;
      case HabitCategory.nutrition:
        return Icons.restaurant;
      case HabitCategory.sleep:
        return Icons.bedtime;
      case HabitCategory.productivity:
        return Icons.rocket_launch;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.social:
        return Icons.people;
      case HabitCategory.creative:
        return Icons.palette;
      case HabitCategory.custom:
        return Icons.star;
    }
  }

  IconData _getGrowthStageIcon(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return Icons.eco;
      case GrowthStage.sprout:
        return Icons.grass;
      case GrowthStage.sapling:
        return Icons.park;
      case GrowthStage.tree:
        return Icons.forest;
      case GrowthStage.forest:
        return Icons.landscape;
    }
  }

  String _getGrowthStageName(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return 'Seed';
      case GrowthStage.sprout:
        return 'Sprout';
      case GrowthStage.sapling:
        return 'Sapling';
      case GrowthStage.tree:
        return 'Tree';
      case GrowthStage.forest:
        return 'Forest';
    }
  }
}
