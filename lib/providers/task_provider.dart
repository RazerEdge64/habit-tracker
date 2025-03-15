import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;

  TaskProvider({required DatabaseService databaseService}) 
      : _databaseService = databaseService {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _databaseService.getTasksForDate(_selectedDate);
    notifyListeners();
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadTasks();
  }

  Future<void> addTask(Task task) async {
    await _databaseService.insertTask(task);
    await _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _databaseService.updateTask(task);
    await _loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _databaseService.deleteTask(id);
    await _loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<Task> getIncompleteTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
  }
} 