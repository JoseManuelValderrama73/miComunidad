import 'package:flutter/material.dart';

class Themes {
  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey[200]!.withOpacity(1),
      colorScheme: const ColorScheme.light());
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey[900]!.withOpacity(1),
      colorScheme: const ColorScheme.dark());
}
