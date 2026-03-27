import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedColor = 'Purple';

  ThemeMode get themeMode => _themeMode;
  String get selectedColor => _selectedColor;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final t = p.getString('theme_mode') ?? 'system';
    _themeMode = t == 'light' ? ThemeMode.light : t == 'dark' ? ThemeMode.dark : ThemeMode.system;
    _selectedColor = p.getString('accent_color') ?? 'Purple';
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final p = await SharedPreferences.getInstance();
    final s = mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system';
    await p.setString('theme_mode', s);
    notifyListeners();
  }

  Future<void> setColor(String name) async {
    _selectedColor = name;
    final p = await SharedPreferences.getInstance();
    await p.setString('accent_color', name);
    notifyListeners();
  }
}
