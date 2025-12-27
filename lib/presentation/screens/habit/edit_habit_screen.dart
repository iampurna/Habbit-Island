import 'package:flutter/material.dart';
import 'package:habbit_island/domain/entities/habit.dart';

class EditHabitScreen extends StatelessWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
      body: const Center(child: Text('Edit Habit - Implementation TBD')),
    );
  }
}
