import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: const Color(0xFF12191D),
  ),

  scaffoldBackgroundColor: AppColors.ink,
  textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),

  cardTheme: CardThemeData(
    color: const Color(0xFF12191D),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF12191D),
  ),

  dividerColor: const Color(0xFF222222),
);