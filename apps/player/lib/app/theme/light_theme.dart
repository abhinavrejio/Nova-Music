import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import '../../models/app_settings.dart';

ThemeData buildLightTheme(AppSettings settings) => ThemeData(
  useMaterial3: true,

  colorScheme:
      ColorScheme.fromSeed(
        seedColor: Color(settings.accentColorValue),
        brightness: Brightness.light,
      ).copyWith(
        primary: Color(settings.accentColorValue),
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
      ),

  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.spaceGroteskTextTheme(),

  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: Color(settings.accentColorValue).withValues(alpha: 0.20),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      borderSide: BorderSide.none,
    ),
  ),
);
