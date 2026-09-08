import 'package:flutter/material.dart';

import 'colors.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ),

  scaffoldBackgroundColor: Colors.black,

  cardTheme: CardThemeData(
    color: const Color(0xFF101010),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF111111),
  ),

  dividerColor: const Color(0xFF222222),
);