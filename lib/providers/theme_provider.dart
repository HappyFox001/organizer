import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeAccent {
  blue,
  red,
  gold,
  green,
}

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _accentKey = 'themeAccent';
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  ThemeAccent _currentAccent = ThemeAccent.blue;

  bool get isDarkMode => _isDarkMode;
  ThemeAccent get currentAccent => _currentAccent;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool(_themeKey) ?? false;
    _currentAccent = ThemeAccent.values[_prefs.getInt(_accentKey) ?? 0];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> cycleAccentColor() async {
    const values = ThemeAccent.values;
    final currentIndex = values.indexOf(_currentAccent);
    _currentAccent = values[(currentIndex + 1) % values.length];
    await _prefs.setInt(_accentKey, values.indexOf(_currentAccent));
    notifyListeners();
  }

  Color get accentColor {
    switch (_currentAccent) {
      case ThemeAccent.blue:
        return const Color(0xFF2196F3);
      case ThemeAccent.red:
        return const Color(0xFFE91E63);
      case ThemeAccent.gold:
        return const Color(0xFFFFB300);
      case ThemeAccent.green:
        return const Color(0xFF4CAF50);
    }
  }

  Color get secondaryAccentColor {
    switch (_currentAccent) {
      case ThemeAccent.blue:
        return const Color(0xFF03A9F4);
      case ThemeAccent.red:
        return const Color(0xFFF44336);
      case ThemeAccent.gold:
        return const Color(0xFFFFC107);
      case ThemeAccent.green:
        return const Color(0xFF66BB6A);
    }
  }

  ThemeData get theme {
    final baseTheme = _isDarkMode ? getDarkTheme() : getLightTheme();
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: accentColor,
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
        elevation: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: Colors.white,
        indicatorColor: accentColor.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      cardTheme: CardTheme(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: accentColor,
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
        elevation: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: Colors.grey[900],
        indicatorColor: accentColor.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
    );
  }
}
