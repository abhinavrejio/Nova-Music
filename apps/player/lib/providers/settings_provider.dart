import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = "theme_mode";
  static const _glassKey = "liquid_glass";
  static const _zoomKey = "ui_scale";
  static const _hardwareKey = "hardware_acceleration";
  static const _autoPlayKey = "auto_play";
  static const _qualityKey = "high_quality_audio";
  static const _volumeBoostKey = "volume_boost";

  @override
  AppSettings build() {
    _load();
    return AppSettings.defaults;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    final storedUiScale = prefs.getDouble(_zoomKey) ?? 1.0;

    state = state.copyWith(
      themeMode: ThemeMode.values[themeIndex],
      liquidGlass: prefs.getBool(_glassKey) ?? true,
      uiScale: storedUiScale,
      hardwareAcceleration:
          prefs.getBool(_hardwareKey) ?? true,
        autoPlay: prefs.getBool(_autoPlayKey) ?? true,
        highQualityAudio: prefs.getBool(_qualityKey) ?? true,
        volumeBoost: prefs.getDouble(_volumeBoostKey) ?? 80,
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
    final safeValue = value.clamp(0.9, 1.2);
    state = state.copyWith(uiScale: safeValue);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_zoomKey, safeValue);
  }

  Future<void> setHardwareAcceleration(bool value) async {
    state = state.copyWith(
      hardwareAcceleration: value,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hardwareKey, value);
  }

  Future<void> setAutoPlay(bool value) async {
    state = state.copyWith(autoPlay: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, value);
  }

  Future<void> setHighQualityAudio(bool value) async {
    state = state.copyWith(highQualityAudio: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_qualityKey, value);
  }

  Future<void> setVolumeBoost(double value) async {
    final safeValue = value.clamp(0, 100).toDouble();
    state = state.copyWith(volumeBoost: safeValue);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeBoostKey, safeValue);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);