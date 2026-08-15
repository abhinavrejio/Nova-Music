import 'package:flutter/material.dart';

import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  cardColor: AppColors.card,
  dividerColor: AppColors.divider,

  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    indicatorColor: Color(0xFFE8DDFF),
  ),
);