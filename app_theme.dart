import 'package:flutter/material.dart';

class AppColors {
  static const Map<String, Color> themes = {
    'Purple': Color(0xFF7C3AED),
    'Blue': Color(0xFF2563EB),
    'Green': Color(0xFF059669),
    'Orange': Color(0xFFEA580C),
    'Pink': Color(0xFFDB2777),
    'Teal': Color(0xFF0891B2),
  };

  static Color get(String name) => themes[name] ?? const Color(0xFF7C3AED);
  static List<String> get names => themes.keys.toList();
}

class AppTheme {
  static ThemeData lightTheme(String colorName) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.get(colorName),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData darkTheme(String colorName) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.get(colorName),
        brightness: Brightness.dark,
      ),
    );
  }
}
