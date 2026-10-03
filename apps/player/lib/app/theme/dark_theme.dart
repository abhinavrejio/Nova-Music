import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import '../../models/app_settings.dart';

ThemeData buildDarkTheme(AppSettings settings) {
  final accent =
      Color(settings.accentColorValue);

  final bool amoled =
      settings.amoledBlack;

  final background = amoled
      ? Colors.black
      : AppColors.ink;

  final surface = amoled
      ? const Color(0xFF0A0A0A)
      : const Color(0xFF12191D);

  final divider = amoled
      ? const Color(0xFF202020)
      : const Color(0xFF292929);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: accent,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: surface,
        surfaceContainerLowest: background,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: scheme,

    scaffoldBackgroundColor:
        background,

    textTheme:
        GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
    ),

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    navigationBarTheme:
        NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor:
          accent.withValues(alpha: 0.20),
    ),

    navigationRailTheme:
        NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor:
          accent.withValues(alpha: 0.20),
    ),

    switchTheme:
        SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return Colors.white;
          }

          return const Color(0xFFB0A3A3);
        },
      ),
      trackColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return accent;
          }

          return const Color(0xFF302C2E);
        },
      ),
    ),

    dividerColor: divider,
  );
}