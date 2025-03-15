import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../services/database_service.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<Habit> _habits = [];
  List<Habit> _todayHabits = [];
  DateTime _selectedDate = DateTime.now();
  
  List<Habit> get habits => _habits;
  List<Habit> get todayHabits => _todayHabits;
  DateTime get selectedDate => _selectedDate;

  HabitProvider({required DatabaseService databaseService})
      : _databaseService = databaseService {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    _habits = await _databaseService.getHabits();
    _todayHabits = await _databaseService.getHabitsForDate(_selectedDate);
    notifyListeners();
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadHabitsForSelectedDate();
  }

  Future<void> _loadHabitsForSelectedDate() async {
    _todayHabits = await _databaseService.getHabitsForDate(_selectedDate);
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _databaseService.insertHabit(habit);
    await _loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _databaseService.updateHabit(habit);
    await _loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await _databaseService.deleteHabit(id);
    await _loadHabits();
  }

  Future<void> toggleHabitCompletion(Habit habit, DateTime date, bool completed) async {
    final updatedHabit = habit.copyWith();
    updatedHabit.markCompleted(date, completed);
    await updateHabit(updatedHabit);
  }

  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  List<String> getAllCategories() {
    final categories = _habits.map((habit) => habit.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Map<String, int> getCategoryCompletionStats() {
    final stats = <String, int>{};
    final categories = getAllCategories();
    
    for (final category in categories) {
      final habitsInCategory = getHabitsByCategory(category);
      int completedCount = 0;
      
      for (final habit in habitsInCategory) {
        if (habit.isCompletedForDate(_selectedDate)) {
          completedCount++;
        }
      }
      
      stats[category] = habitsInCategory.isEmpty 
          ? 0 
          : (completedCount * 100 ~/ habitsInCategory.length);
    }
    
    return stats;
  }

  // Get completion rate for a specific habit over the last n days
  Map<DateTime, bool> getHabitCompletionHistory(Habit habit, int days) {
    final history = <DateTime, bool>{};
    final today = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      if (habit.isScheduledForDate(date)) {
        history[date] = habit.isCompletedForDate(date);
      }
    }
    
    return history;
  }
} 