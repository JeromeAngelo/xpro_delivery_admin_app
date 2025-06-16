import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpro_delivery_admin_app/core/common/widgets/app_structure/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themeModeKey = 'theme_mode';

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  
  // Current theme data based on mode
  ThemeData get theme {
    if (_themeMode == ThemeMode.light) {
      return AppTheme.light;
    } else if (_themeMode == ThemeMode.dark) {
      return AppTheme.dark;
    } else {
      // System theme
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
    }
  }

  // Get current theme mode name for display
  String get currentThemeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Load saved theme mode preference
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(_themeModeKey);
      
      if (savedThemeMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedThemeMode,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  // Set and save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}
