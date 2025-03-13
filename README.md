# Habit Tracker

A Flutter-based habit tracking application that helps you build and maintain daily habits and tasks.

## Features

### Today's Tasks
- Daily to-do list that refreshes each day
- Mark tasks as complete/incomplete
- Set priority levels (high/medium/low)
- Add time-based reminders
- View task history with a calendar

### Habit Checklist
- Track recurring habits organized by category
- Simple toggle system to mark habits as complete
- View streak counters for each habit
- Filter habits by category

### Habit Management
- Create, edit, and delete habits
- Set frequency (daily, weekdays, weekends, weekly, custom)
- Group habits into categories
- Set start/end dates for temporary habits
- Add notes to habits

### Progress Visualization
- View completion rates over time
- See streak leaderboard
- Filter statistics by time period and category
- Track overall habit completion rate

### Settings
- User profile with basic info
- Theme customization (light/dark mode)
- Notification preferences

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio / Xcode (for running on devices/emulators)

### Installation

1. Clone the repository
```
git clone https://github.com/yourusername/habit_tracker.git
```

2. Navigate to the project directory
```
cd habit_tracker
```

3. Install dependencies
```
flutter pub get
```

4. Run the app
```
flutter run
```

## Technical Details

### Architecture
- Flutter for UI
- Provider for state management
- SQLite for local data storage
- Shared Preferences for user settings

### Key Packages
- provider: State management
- sqflite: Local database
- fl_chart: Charts and graphs
- table_calendar: Calendar widget
- flutter_slidable: Swipeable list items

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All the package authors that made this app possible
