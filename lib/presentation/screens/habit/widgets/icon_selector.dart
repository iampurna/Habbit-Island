import 'package:flutter/material.dart';
import 'package:habbit_island/core/constants/island_constants.dart';

class IconSelector extends StatelessWidget {
  final HabitCategory selectedCategory;
  final Function(HabitCategory) onSelected;

  const IconSelector({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: HabitCategory.values.map((category) {
        final isSelected = category == selectedCategory;
        return GestureDetector(
          onTap: () => onSelected(category),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
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
      case HabitCategory.reading:
        //DO: Handle this case.
        return Icons.menu_book;
      case HabitCategory.meditation:
        //DO: Handle this case.
        return Icons.self_improvement;
    }
  }
}
