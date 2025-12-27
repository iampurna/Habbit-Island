import 'package:flutter/material.dart';

class ReminderToggle extends StatefulWidget {
  final String? reminderTime;
  final Function(String?) onChanged;

  const ReminderToggle({super.key, this.reminderTime, required this.onChanged});

  @override
  State<ReminderToggle> createState() => _ReminderToggleState();
}

class _ReminderToggleState extends State<ReminderToggle> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.reminderTime != null;
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      widget.onChanged(time.format(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text('Daily Reminder'),
        subtitle: _enabled && widget.reminderTime != null
            ? Text(widget.reminderTime!)
            : null,
        value: _enabled,
        onChanged: (value) {
          setState(() => _enabled = value);
          if (value) {
            _selectTime();
          } else {
            widget.onChanged(null);
          }
        },
        secondary: const Icon(Icons.notifications),
      ),
    );
  }
}
