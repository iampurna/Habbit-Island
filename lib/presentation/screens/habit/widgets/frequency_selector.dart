import 'package:flutter/material.dart';
import 'package:habbit_island/data/models/habit_model.dart';

class FrequencySelector extends StatelessWidget {
  final HabitFrequency selectedFrequency;
  final Function(HabitFrequency) onSelected;

  const FrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: HabitFrequency.values.map((frequency) {
        final isSelected = frequency == selectedFrequency;
        return ChoiceChip(
          label: Text(_getFrequencyLabel(frequency)),
          selected: isSelected,
          onSelected: (selected) => onSelected(frequency),
        );
      }).toList(),
    );
  }

  String _getFrequencyLabel(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }
}
