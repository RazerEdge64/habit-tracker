import 'package:uuid/uuid.dart';

enum TaskPriority { high, medium, low }

class Task {
  final String id;
  String title;
  bool isCompleted;
  TaskPriority priority;
  DateTime date;
  DateTime? reminderTime;

  Task({
    String? id,
    required this.title,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    DateTime? date,
    this.reminderTime,
  }) : 
    id = id ?? const Uuid().v4(),
    date = date ?? DateTime.now();

  // Create a copy of the task with updated fields
  Task copyWith({
    String? title,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? date,
    DateTime? reminderTime,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  // Convert task to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority.index,
      'date': date.millisecondsSinceEpoch,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
    };
  }

  // Create a task from a map (from database)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      priority: TaskPriority.values[map['priority']],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      reminderTime: map['reminderTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime'])
          : null,
    );
  }
} 