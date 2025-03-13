import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const TaskFormScreen({
    super.key,
    this.task,
    this.initialDate,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;
  DateTime? _reminderTime;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing task data or defaults
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedDate = widget.task?.date ?? widget.initialDate ?? DateTime.now();
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _reminderTime = widget.task?.reminderTime;
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Task title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.task_alt),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date picker
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
              leading: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 8),

            // Priority selector
            const Text('Priority'),
            Row(
              children: [
                _buildPriorityOption(TaskPriority.high, 'High', Colors.red),
                _buildPriorityOption(TaskPriority.medium, 'Medium', Colors.orange),
                _buildPriorityOption(TaskPriority.low, 'Low', Colors.green),
              ],
            ),
            const SizedBox(height: 16),

            // Reminder time
            ListTile(
              title: const Text('Reminder'),
              subtitle: _reminderTime != null
                  ? Text(DateFormat.jm().format(_reminderTime!))
                  : const Text('No reminder set'),
              leading: const Icon(Icons.alarm),
              trailing: _reminderTime != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _reminderTime = null;
                        });
                      },
                    )
                  : null,
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),

            // Completed checkbox
            CheckboxListTile(
              title: const Text('Mark as completed'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(TaskPriority priority, String label, Color color) {
    return Expanded(
      child: RadioListTile<TaskPriority>(
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        value: priority,
        groupValue: _selectedPriority,
        onChanged: (value) {
          setState(() {
            _selectedPriority = value!;
          });
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _reminderTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (widget.task == null) {
        // Create new task
        final newTask = Task(
          title: _titleController.text.trim(),
          date: _selectedDate,
          priority: _selectedPriority,
          reminderTime: _reminderTime,
          isCompleted: _isCompleted,
        );
        taskProvider.addTask(newTask);
      } else {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          date: _selectedDate,
          priority: _selectedPriority,
          reminderTime: _reminderTime,
          isCompleted: _isCompleted,
        );
        taskProvider.updateTask(updatedTask);
      }
      
      Navigator.pop(context);
    }
  }
} 