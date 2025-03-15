import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/habit.dart';
import 'database_service.dart';

class SampleDataService {
  static const String _hasLoadedSampleDataKey = 'has_loaded_sample_data';
  
  // Add sample data if it hasn't been added before
  static Future<void> addSampleDataIfNeeded(DatabaseService databaseService) async {
    final prefs = await SharedPreferences.getInstance();
    final hasLoadedSampleData = prefs.getBool(_hasLoadedSampleDataKey) ?? false;
    
    if (!hasLoadedSampleData) {
      await _addSampleTasks(databaseService);
      await _addSampleHabits(databaseService);
      
      // Mark sample data as loaded
      await prefs.setBool(_hasLoadedSampleDataKey, true);
      print('Sample data added successfully');
    }
  }
  
  // Add sample tasks
  static Future<void> _addSampleTasks(DatabaseService databaseService) async {
    final today = DateTime.now();
    
    final tasks = [
      Task(
        title: 'Complete Flutter tutorial',
        priority: TaskPriority.high,
        date: today,
      ),
      Task(
        title: 'Go for a 30-minute walk',
        priority: TaskPriority.medium,
        date: today,
      ),
      Task(
        title: 'Read a book for 20 minutes',
        priority: TaskPriority.low,
        date: today,
      ),
      Task(
        title: 'Plan meals for the week',
        priority: TaskPriority.medium,
        date: today.add(const Duration(days: 1)),
      ),
      Task(
        title: 'Call mom',
        priority: TaskPriority.high,
        date: today.add(const Duration(days: 1)),
        reminderTime: today.add(const Duration(days: 1, hours: 18)),
      ),
    ];
    
    for (final task in tasks) {
      await databaseService.insertTask(task);
    }
  }
  
  // Add sample habits
  static Future<void> _addSampleHabits(DatabaseService databaseService) async {
    final habits = [
      Habit(
        title: 'Drink 8 glasses of water',
        category: 'Health',
        frequency: HabitFrequency.daily,
      ),
      Habit(
        title: 'Meditate for 10 minutes',
        category: 'Mindfulness',
        frequency: HabitFrequency.daily,
      ),
      Habit(
        title: 'Exercise',
        category: 'Health',
        frequency: HabitFrequency.weekdays,
      ),
      Habit(
        title: 'Review goals',
        category: 'Productivity',
        frequency: HabitFrequency.weekly,
      ),
      Habit(
        title: 'Clean the house',
        category: 'Home',
        frequency: HabitFrequency.weekends,
      ),
    ];
    
    for (final habit in habits) {
      await databaseService.insertHabit(habit);
    }
  }
} 