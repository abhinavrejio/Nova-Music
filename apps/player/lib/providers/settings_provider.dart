import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = "theme_mode";
  static const _glassKey = "liquid_glass";
  static const _zoomKey = "ui_scale";
  static const _hardwareKey = "hardware_acceleration";

  @override
  AppSettings build() {
    _load();
    return AppSettings.defaults;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;

    state = state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      liquidGlass: prefs.getBool(_glassKey) ?? true,
      uiScale: prefs.getDouble(_zoomKey) ?? 1.0,
      hardwareAcceleration:
          prefs.getBool(_hardwareKey) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setLiquidGlass(bool value) async {
    state = state.copyWith(liquidGlass: value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_glassKey, value);
  }

  Future<void> setUiScale(double value) async {
  state = state.copyWith(uiScale: value);

  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_zoomKey, value);
}

Future<void> setHardwareAcceleration(bool value) async {
  state = state.copyWith(
    hardwareAcceleration: value,
  );

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_hardwareKey, value);
}
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);