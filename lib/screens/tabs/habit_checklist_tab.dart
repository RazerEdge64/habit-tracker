import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class HabitChecklistTab extends StatefulWidget {
  const HabitChecklistTab({super.key});

  @override
  State<HabitChecklistTab> createState() => _HabitChecklistTabState();
}

class _HabitChecklistTabState extends State<HabitChecklistTab> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _showCalendar = false;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final habits = habitProvider.todayHabits;
        final selectedDate = habitProvider.selectedDate;
        final categories = habitProvider.getAllCategories();
        
        // Filter habits by selected category
        final filteredHabits = _selectedCategory != null
            ? habits.where((h) => h.category == _selectedCategory).toList()
            : habits;
        
        return Scaffold(
          body: Column(
            children: [
              // Date selector with expandable calendar
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCalendar = !_showCalendar;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        _showCalendar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Calendar (collapsible)
              if (_showCalendar)
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDate,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    habitProvider.changeSelectedDate(selectedDay);
                    setState(() {
                      _showCalendar = false;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                ),
              
              // Category filter
              if (categories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: _selectedCategory,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      )).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              
              // Habit list
              Expanded(
                child: filteredHabits.isEmpty
                    ? _buildEmptyState()
                    : _buildHabitList(filteredHabits, habitProvider, selectedDate),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits for today',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add habits in the Habits tab',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList(List<Habit> habits, HabitProvider habitProvider, DateTime selectedDate) {
    // Group habits by category
    final Map<String, List<Habit>> habitsByCategory = {};
    
    for (final habit in habits) {
      if (!habitsByCategory.containsKey(habit.category)) {
        habitsByCategory[habit.category] = [];
      }
      habitsByCategory[habit.category]!.add(habit);
    }
    
    // Sort categories alphabetically
    final sortedCategories = habitsByCategory.keys.toList()..sort();
    
    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final habitsInCategory = habitsByCategory[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            ...habitsInCategory.map((habit) => _buildHabitItem(habit, habitProvider, selectedDate)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildHabitItem(Habit habit, HabitProvider habitProvider, DateTime selectedDate) {
    final isCompleted = habit.isCompletedForDate(selectedDate);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            habitProvider.toggleHabitCompletion(habit, selectedDate, value ?? false);
          },
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${habit.streak} day streak',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 