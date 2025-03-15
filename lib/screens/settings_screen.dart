import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../services/sample_data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: Provider.of<SettingsProvider>(context, listen: false).userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Profile Section
              const Text(
                'User Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) {
                  // Don't update in real-time to avoid excessive rebuilds
                },
                onSubmitted: (value) {
                  settings.setUserName(value);
                },
              ),
              const SizedBox(height: 24),

              // Appearance Section
              const Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.setDarkMode(value);
                },
              ),
              const SizedBox(height: 24),

              // Notifications Section
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get reminders for your tasks and habits'),
                value: settings.useNotifications,
                onChanged: (value) {
                  settings.setUseNotifications(value);
                },
              ),
              const SizedBox(height: 24),

              // About Section
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info_outline),
              ),
              const SizedBox(height: 16),
              
              // Save button for name changes
              ElevatedButton(
                onPressed: () {
                  settings.setUserName(_nameController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
                child: const Text('Save Changes'),
              ),

              // Debug section
              _buildResetSampleDataButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResetSampleDataButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.refresh),
      title: const Text('Reset Sample Data'),
      subtitle: const Text('Clear and reload sample tasks and habits'),
      onTap: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Sample Data'),
            content: const Text(
              'This will clear all existing tasks and habits and reload the sample data. '
              'This action cannot be undone. Are you sure?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          // Reset sample data flag
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_loaded_sample_data', false);
          
          // Get database service and reload sample data
          final databaseService = DatabaseService();
          await databaseService.clearAllData();
          await SampleDataService.addSampleDataIfNeeded(databaseService);
          
          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sample data has been reset'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }
} 