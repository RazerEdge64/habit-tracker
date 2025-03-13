import 'package:uuid/uuid.dart';

enum HabitFrequency { daily, weekdays, weekends, weekly, custom }

class Habit {
  final String id;
  String title;
  String category;
  HabitFrequency frequency;
  List<bool> activeDays; // For custom frequency: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  DateTime startDate;
  DateTime? endDate;
  String? notes;
  int streak;
  Map<String, bool> completionHistory; // Date string -> completed

  Habit({
    String? id,
    required this.title,
    this.category = 'General',
    this.frequency = HabitFrequency.daily,
    List<bool>? activeDays,
    DateTime? startDate,
    this.endDate,
    this.notes,
    this.streak = 0,
    Map<String, bool>? completionHistory,
  }) : 
    id = id ?? const Uuid().v4(),
    startDate = startDate ?? DateTime.now(),
    activeDays = activeDays ?? List.filled(7, true),
    completionHistory = completionHistory ?? {};

  // Create a copy of the habit with updated fields
  Habit copyWith({
    String? title,
    String? category,
    HabitFrequency? frequency,
    List<bool>? activeDays,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    int? streak,
    Map<String, bool>? completionHistory,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      activeDays: activeDays ?? List.from(this.activeDays),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      streak: streak ?? this.streak,
      completionHistory: completionHistory ?? Map.from(this.completionHistory),
    );
  }

  // Check if habit is scheduled for a specific date
  bool isScheduledForDate(DateTime date) {
    // Don't show habits before start date or after end date
    if (date.isBefore(startDate) || (endDate != null && date.isAfter(endDate!))) {
      return false;
    }

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return date.weekday >= 1 && date.weekday <= 5;
      case HabitFrequency.weekends:
        return date.weekday == 6 || date.weekday == 7;
      case HabitFrequency.weekly:
        // Check if it's the same weekday as the start date
        return date.weekday == startDate.weekday;
      case HabitFrequency.custom:
        // Check if the weekday is active (0 = Monday, 6 = Sunday)
        return activeDays[date.weekday - 1];
    }
  }

  // Mark habit as completed for a specific date
  void markCompleted(DateTime date, bool completed) {
    final dateString = _dateToString(date);
    completionHistory[dateString] = completed;
    
    // Update streak
    _updateStreak();
  }

  // Check if habit is completed for a specific date
  bool isCompletedForDate(DateTime date) {
    final dateString = _dateToString(date);
    return completionHistory[dateString] ?? false;
  }

  // Update streak count
  void _updateStreak() {
    int currentStreak = 0;
    DateTime today = DateTime.now();
    DateTime date = today;
    
    // Count backwards from today
    while (true) {
      final dateString = _dateToString(date);
      
      // If the habit is scheduled for this date
      if (isScheduledForDate(date)) {
        // If completed, increment streak
        if (completionHistory[dateString] == true) {
          currentStreak++;
        } else {
          // Break on first incomplete scheduled habit
          break;
        }
      }
      
      // Move to previous day
      date = date.subtract(const Duration(days: 1));
      
      // Stop if we go before start date
      if (date.isBefore(startDate)) {
        break;
      }
    }
    
    streak = currentStreak;
  }

  // Helper to convert date to string format for the map
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // Convert habit to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'frequency': frequency.index,
      'activeDays': activeDays.map((day) => day ? 1 : 0).toList().join(','),
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'notes': notes,
      'streak': streak,
      'completionHistory': completionHistory.entries
          .map((e) => '${e.key}:${e.value ? 1 : 0}')
          .join(';'),
    };
  }

  // Create a habit from a map (from database)
  factory Habit.fromMap(Map<String, dynamic> map) {
    // Parse active days
    List<bool> activeDays = (map['activeDays'] as String)
        .split(',')
        .map((day) => day == '1')
        .toList();
    
    // Parse completion history
    Map<String, bool> completionHistory = {};
    if (map['completionHistory'] != null && map['completionHistory'].isNotEmpty) {
      completionHistory = Map.fromEntries(
        (map['completionHistory'] as String).split(';').map((entry) {
          final parts = entry.split(':');
          return MapEntry(parts[0], parts[1] == '1');
        }),
      );
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      frequency: HabitFrequency.values[map['frequency']],
      activeDays: activeDays,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'])
          : null,
      notes: map['notes'],
      streak: map['streak'],
      completionHistory: completionHistory,
    );
  }
} 