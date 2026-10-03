import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';
import '../../models/app_settings.dart';

class AppTheme {
  static ThemeData light(AppSettings settings) => buildLightTheme(settings);

  static ThemeData dark(AppSettings settings) => buildDarkTheme(settings);
}
