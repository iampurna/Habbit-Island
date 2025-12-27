import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habbit_island/core/constants/island_constants.dart';
import 'package:habbit_island/data/models/habit_model.dart' hide HabitCategory;
import '../../blocs/habit/habit_bloc.dart';
import '../../blocs/habit/habit_event.dart';
import '../../blocs/habit/habit_state.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';
import 'widgets/frequency_selector.dart';
import 'widgets/icon_selector.dart';
import 'widgets/reminder_toggle.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitCategory _selectedCategory = HabitCategory.custom;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  String _selectedZone = 'starter-beach';
  String? _reminderTime;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      context.read<HabitBloc>().add(
        HabitCreateRequested(
          userId: 'current_user_id',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          frequency: _selectedFrequency,
          zoneId: _selectedZone,
          reminderTime: _reminderTime,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BlocListener<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitCreated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Habit created successfully!')),
            );
          } else if (state is HabitError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  label: 'Habit Name',
                  hint: 'e.g., Drink Water',
                  controller: _nameController,
                  prefixIcon: Icons.create,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Description (Optional)',
                  hint: 'Add details about this habit',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                IconSelector(
                  selectedCategory: _selectedCategory,
                  onSelected: (category) =>
                      setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: 24),
                Text(
                  'Frequency',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                FrequencySelector(
                  selectedFrequency: _selectedFrequency,
                  onSelected: (frequency) =>
                      setState(() => _selectedFrequency = frequency),
                ),
                const SizedBox(height: 24),
                ReminderToggle(
                  reminderTime: _reminderTime,
                  onChanged: (time) => setState(() => _reminderTime = time),
                ),
                const SizedBox(height: 40),
                BlocBuilder<HabitBloc, HabitState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      text: 'Create Habit',
                      onPressed: _saveHabit,
                      isLoading: state is HabitLoading,
                      icon: Icons.check,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
