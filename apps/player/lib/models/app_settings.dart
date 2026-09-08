import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final bool liquidGlass;
  final double uiScale;
  final bool hardwareAcceleration;

  const AppSettings({
    required this.themeMode,
    required this.liquidGlass,
    required this.uiScale,
    required this.hardwareAcceleration,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? liquidGlass,
    double? uiScale,
    bool? hardwareAcceleration,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      uiScale: uiScale ?? this.uiScale,
      hardwareAcceleration:
          hardwareAcceleration ?? this.hardwareAcceleration,
    );
  }

  static const defaults = AppSettings(
    themeMode: ThemeMode.system,
    liquidGlass: true,
    uiScale: 1.0,
    hardwareAcceleration: true,
  );
}