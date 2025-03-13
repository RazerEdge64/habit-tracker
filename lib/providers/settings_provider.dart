import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  String _userName = '';
  bool _useNotifications = true;
  
  bool get isDarkMode => _isDarkMode;
  String get userName => _userName;
  bool get useNotifications => _useNotifications;
  
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _userName = _prefs.getString('userName') ?? '';
    _useNotifications = _prefs.getBool('useNotifications') ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs.setString('userName', name);
    notifyListeners();
  }

  Future<void> setUseNotifications(bool value) async {
    _useNotifications = value;
    await _prefs.setBool('useNotifications', value);
    notifyListeners();
  }
} 