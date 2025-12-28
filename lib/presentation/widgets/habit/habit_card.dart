import 'package:flutter/material.dart';
import '../../../../domain/entities/habit.dart';

/// Simple Habit Card for Today Screen
/// Note: Main HabitCard is in presentation/widgets/habit/habit_card.dart
/// This is a simplified version for the today screen specifically
class TodayHabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const TodayHabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = _checkIsCompletedToday();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),

              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      '${habit.currentStreak} day streak',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Complete button
              if (onComplete != null)
                IconButton(
                  onPressed: isCompleted ? null : onComplete,
                  icon: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _checkIsCompletedToday() {
    // Simple check - in production this would check lastCompletedAt
    // against today's date properly
    if (habit.lastCompletedAt == null) return false;

    final now = DateTime.now();
    final lastCompleted = habit.lastCompletedAt!;

    return now.year == lastCompleted.year &&
        now.month == lastCompleted.month &&
        now.day == lastCompleted.day;
  }
}
