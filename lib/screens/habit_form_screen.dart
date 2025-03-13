import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({
    super.key,
    this.habit,
  });

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late HabitFrequency _frequency;
  late List<bool> _activeDays;
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing habit data or defaults
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _categoryController = TextEditingController(text: widget.habit?.category ?? 'General');
    _notesController = TextEditingController(text: widget.habit?.notes ?? '');
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _activeDays = widget.habit?.activeDays ?? List.filled(7, true);
    _startDate = widget.habit?.startDate ?? DateTime.now();
    _endDate = widget.habit?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Habit title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                hintText: 'Enter habit title',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Enter category (e.g., Health, Productivity)',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),

            // Frequency selector
            const Text('Frequency'),
            DropdownButtonFormField<HabitFrequency>(
              value: _frequency,
              items: HabitFrequency.values.map((frequency) {
                return DropdownMenuItem<HabitFrequency>(
                  value: frequency,
                  child: Text(_getFrequencyText(frequency)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Custom days selector (only show if frequency is custom)
            if (_frequency == HabitFrequency.custom)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Days'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDayToggle(0, 'M'),
                      _buildDayToggle(1, 'T'),
                      _buildDayToggle(2, 'W'),
                      _buildDayToggle(3, 'T'),
                      _buildDayToggle(4, 'F'),
                      _buildDayToggle(5, 'S'),
                      _buildDayToggle(6, 'S'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Start date
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(DateFormat.yMMMd().format(_startDate)),
              leading: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
            const SizedBox(height: 8),

            // End date (optional)
            ListTile(
              title: const Text('End Date (Optional)'),
              subtitle: _endDate != null
                  ? Text(DateFormat.yMMMd().format(_endDate!))
                  : const Text('No end date'),
              leading: const Icon(Icons.calendar_today),
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _endDate = null;
                        });
                      },
                    )
                  : null,
              onTap: _selectEndDate,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveHabit,
              child: const Text('Save Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayToggle(int index, String label) {
    return Column(
      children: [
        Text(label),
        Checkbox(
          value: _activeDays[index],
          onChanged: (value) {
            setState(() {
              _activeDays[index] = value!;
            });
          },
        ),
      ],
    );
  }

  String _getFrequencyText(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Every day';
      case HabitFrequency.weekdays:
        return 'Weekdays (Mon-Fri)';
      case HabitFrequency.weekends:
        return 'Weekends (Sat-Sun)';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.custom:
        return 'Custom days';
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      
      if (widget.habit == null) {
        // Create new habit
        final newHabit = Habit(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          frequency: _frequency,
          activeDays: _activeDays,
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.trim(),
        );
        habitProvider.addHabit(newHabit);
      } else {
        // Update existing habit
        final updatedHabit = widget.habit!.copyWith(
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          frequency: _frequency,
          activeDays: _activeDays,
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.trim(),
        );
        habitProvider.updateHabit(updatedHabit);
      }
      
      Navigator.pop(context);
    }
  }
} 