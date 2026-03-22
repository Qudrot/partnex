import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_themeKey);
    if (themeStr != null) {
      if (themeStr == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.light);
      }
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
