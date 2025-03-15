import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/sample_data_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service
  final databaseService = DatabaseService();
  try {
    await databaseService.initialize();
    print('Database initialized successfully');
  } catch (e) {
    print('Error initializing database: $e');
    // Continue with app startup even if database fails
    // This allows the app to run on platforms where SQLite isn't fully supported
  }
  
  // Add sample data if needed
  await SampleDataService.addSampleDataIfNeeded(databaseService);
  
  // Run the app
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  
  const MyApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(databaseService: databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(databaseService: databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Habit Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
