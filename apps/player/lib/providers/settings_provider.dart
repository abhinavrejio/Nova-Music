import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  static const _settingsKey = 'app_settings';

  @override
  AppSettings build() {
    _load();
    return AppSettings.defaults;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(_settingsKey);

    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      state = AppSettings(
        themeMode: _themeModeFromString(decoded['themeMode'] as String?),
        liquidGlass: decoded['liquidGlass'] as bool? ?? AppSettings.defaults.liquidGlass,
        uiScale: (decoded['uiScale'] as num?)?.toDouble() ?? AppSettings.defaults.uiScale,
        hardwareAcceleration: decoded['hardwareAcceleration'] as bool? ?? AppSettings.defaults.hardwareAcceleration,
        amoledBlack: decoded['amoledBlack'] as bool? ?? AppSettings.defaults.amoledBlack,
        showGradient: decoded['showGradient'] as bool? ?? AppSettings.defaults.showGradient,
        accentColorValue: (decoded['accentColorValue'] as num?)?.toInt() ?? AppSettings.defaults.accentColorValue,
        autoPlay: decoded['autoPlay'] as bool? ?? AppSettings.defaults.autoPlay,
        highQualityAudio: decoded['highQualityAudio'] as bool? ?? AppSettings.defaults.highQualityAudio,
        searchShowSongs: decoded['searchShowSongs'] as bool? ?? AppSettings.defaults.searchShowSongs,
        searchShowPlaylists: decoded['searchShowPlaylists'] as bool? ?? AppSettings.defaults.searchShowPlaylists,
        shuffle: decoded['shuffle'] as bool? ?? AppSettings.defaults.shuffle,
        repeatMode: (decoded['repeatMode'] as num?)?.toInt() ?? AppSettings.defaults.repeatMode,
        miniPlayerShowShuffle: decoded['miniPlayerShowShuffle'] as bool? ?? AppSettings.defaults.miniPlayerShowShuffle,
        miniPlayerShowRepeat: decoded['miniPlayerShowRepeat'] as bool? ?? AppSettings.defaults.miniPlayerShowRepeat,
        miniPlayerShowQueue: decoded['miniPlayerShowQueue'] as bool? ?? AppSettings.defaults.miniPlayerShowQueue,
        compactSidebar: decoded['compactSidebar'] as bool? ?? AppSettings.defaults.compactSidebar,
        sidebarShowTagline: decoded['sidebarShowTagline'] as bool? ?? AppSettings.defaults.sidebarShowTagline,
      );
    } catch (_) {
      state = AppSettings.defaults;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'themeMode': state.themeMode.name,
      'liquidGlass': state.liquidGlass,
      'uiScale': state.uiScale,
      'hardwareAcceleration': state.hardwareAcceleration,
      'amoledBlack': state.amoledBlack,
      'showGradient': state.showGradient,
      'accentColorValue': state.accentColorValue,
      'autoPlay': state.autoPlay,
      'highQualityAudio': state.highQualityAudio,
      'searchShowSongs': state.searchShowSongs,
      'searchShowPlaylists': state.searchShowPlaylists,
      'shuffle': state.shuffle,
      'repeatMode': state.repeatMode,
      'miniPlayerShowShuffle': state.miniPlayerShowShuffle,
      'miniPlayerShowRepeat': state.miniPlayerShowRepeat,
      'miniPlayerShowQueue': state.miniPlayerShowQueue,
      'compactSidebar': state.compactSidebar,
      'sidebarShowTagline': state.sidebarShowTagline,
    };

    await prefs.setString(_settingsKey, jsonEncode(payload));
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode value) {
    state = state.copyWith(themeMode: value);
    _persist();
  }

  void setLiquidGlass(bool value) {
    state = state.copyWith(liquidGlass: value);
    _persist();
  }

  void setUiScale(double value) {
    state = state.copyWith(uiScale: value);
    _persist();
  }

  void setAmoledBlack(bool value) {
    state = state.copyWith(amoledBlack: value);
    _persist();
  }

  void setBackgroundGradient(bool value) {
    setShowGradient(value);
  }

  void setShowGradient(bool value) {
    state = state.copyWith(showGradient: value);
    _persist();
  }

  void setAccentColor(int value) {
    state = state.copyWith(accentColorValue: value);
    _persist();
  }

  void setHardwareAcceleration(bool value) {
    state = state.copyWith(hardwareAcceleration: value);
    _persist();
  }

  void setAutoPlay(bool value) {
    state = state.copyWith(autoPlay: value);
    _persist();
  }

  void setHighQualityAudio(bool value) {
    state = state.copyWith(highQualityAudio: value);
    _persist();
  }

  void setSearchShowSongs(bool value) {
    state = state.copyWith(searchShowSongs: value);
    _persist();
  }

  void setSearchShowPlaylists(bool value) {
    state = state.copyWith(searchShowPlaylists: value);
    _persist();
  }

  void setShuffle(bool value) {
    state = state.copyWith(shuffle: value);
    _persist();
  }

  void setRepeatMode(int value) {
    state = state.copyWith(repeatMode: value);
    _persist();
  }

  void setMiniPlayerShowShuffle(bool value) {
    state = state.copyWith(miniPlayerShowShuffle: value);
    _persist();
  }

  void setMiniPlayerShowRepeat(bool value) {
    state = state.copyWith(miniPlayerShowRepeat: value);
    _persist();
  }

  void setMiniPlayerShowQueue(bool value) {
    state = state.copyWith(miniPlayerShowQueue: value);
    _persist();
  }

  void setCompactSidebar(bool value) {
    state = state.copyWith(compactSidebar: value);
    _persist();
  }

  void setSidebarShowTagline(bool value) {
    state = state.copyWith(sidebarShowTagline: value);
    _persist();
  }

  void resetSettings() {
    state = AppSettings.defaults;
    _persist();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);