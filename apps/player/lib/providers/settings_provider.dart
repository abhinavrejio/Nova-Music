import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

const lastPlayedTrackStorageKey = 'last_played_track';

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

    if (rawValue == null || rawValue.isEmpty) return;

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) return;

      const previousDefaultAccent = 0xFFFF6B5F;
      final savedAccent =
          (decoded['accentColorValue'] as num?)?.toInt() ??
          AppSettings.defaults.accentColorValue;
      final savedBackground =
          (decoded['backgroundColorValue'] as num?)?.toInt() ??
          AppSettings.defaults.backgroundColorValue;

      state = AppSettings(
        themeMode: _themeModeFromString(decoded['themeMode'] as String?),
        liquidGlass:
            decoded['liquidGlass'] as bool? ?? AppSettings.defaults.liquidGlass,
        uiScale:
            (decoded['uiScale'] as num?)?.toDouble() ??
            AppSettings.defaults.uiScale,
        hardwareAcceleration:
            decoded['hardwareAcceleration'] as bool? ??
            AppSettings.defaults.hardwareAcceleration,
        amoledBlack:
            decoded['amoledBlack'] as bool? ?? AppSettings.defaults.amoledBlack,
        showGradient:
            decoded['showGradient'] as bool? ??
            AppSettings.defaults.showGradient,
        accentColorValue: savedAccent == previousDefaultAccent
            ? AppSettings.defaults.accentColorValue
            : savedAccent,
        animationsEnabled:
            decoded['animationsEnabled'] as bool? ??
            AppSettings.defaults.animationsEnabled,
        adaptiveGlass:
            decoded['adaptiveGlass'] as bool? ??
            AppSettings.defaults.adaptiveGlass,
        glassQuality: GlassQuality.values.firstWhere(
          (quality) => quality.name == decoded['glassQuality'],
          orElse: () => AppSettings.defaults.glassQuality,
        ),
        glassSurfaceOpacity: AppSettings.clampGlassSurfaceOpacity(
          (decoded['glassSurfaceOpacity'] as num?)?.toDouble() ??
              AppSettings.defaults.glassSurfaceOpacity,
        ),
        autoPlay: decoded['autoPlay'] as bool? ?? AppSettings.defaults.autoPlay,
        crossfadeEnabled:
            decoded['crossfadeEnabled'] as bool? ??
            AppSettings.defaults.crossfadeEnabled,
        crossfadeDurationSeconds:
            ((decoded['crossfadeDurationSeconds'] as num?)?.toInt() ??
                    AppSettings.defaults.crossfadeDurationSeconds)
                .clamp(1, 12)
                .toInt(),
        highQualityAudio:
            decoded['highQualityAudio'] as bool? ??
            AppSettings.defaults.highQualityAudio,
        searchShowSongs:
            decoded['searchShowSongs'] as bool? ??
            AppSettings.defaults.searchShowSongs,
        searchShowPlaylists:
            decoded['searchShowPlaylists'] as bool? ??
            AppSettings.defaults.searchShowPlaylists,
        shuffle: decoded['shuffle'] as bool? ?? AppSettings.defaults.shuffle,
        repeatMode:
            (decoded['repeatMode'] as num?)?.toInt() ??
            AppSettings.defaults.repeatMode,
        restoreLastTrack:
            decoded['restoreLastTrack'] as bool? ??
            AppSettings.defaults.restoreLastTrack,
        miniPlayerShowShuffle:
            decoded['miniPlayerShowShuffle'] as bool? ??
            AppSettings.defaults.miniPlayerShowShuffle,
        miniPlayerShowRepeat:
            decoded['miniPlayerShowRepeat'] as bool? ??
            AppSettings.defaults.miniPlayerShowRepeat,
        miniPlayerShowQueue:
            decoded['miniPlayerShowQueue'] as bool? ??
            AppSettings.defaults.miniPlayerShowQueue,
        compactSidebar:
            decoded['compactSidebar'] as bool? ??
            AppSettings.defaults.compactSidebar,
        sidebarShowTagline:
            decoded['sidebarShowTagline'] as bool? ??
            AppSettings.defaults.sidebarShowTagline,
        leftSidebarWidth: AppSettings.clampLeftSidebarWidth(
          (decoded['leftSidebarWidth'] as num?)?.toDouble() ??
              AppSettings.defaults.leftSidebarWidth,
        ),
        rightSidebarWidth: AppSettings.clampRightSidebarWidth(
          (decoded['rightSidebarWidth'] as num?)?.toDouble() ??
              AppSettings.defaults.rightSidebarWidth,
        ),
        playPauseShortcut:
            decoded['playPauseShortcut'] as String? ??
            AppSettings.defaults.playPauseShortcut,
        seekBackwardShortcut:
            decoded['seekBackwardShortcut'] as String? ??
            AppSettings.defaults.seekBackwardShortcut,
        seekForwardShortcut:
            decoded['seekForwardShortcut'] as String? ??
            AppSettings.defaults.seekForwardShortcut,
        previousTrackShortcut:
            decoded['previousTrackShortcut'] as String? ??
            AppSettings.defaults.previousTrackShortcut,
        nextTrackShortcut:
            decoded['nextTrackShortcut'] as String? ??
            AppSettings.defaults.nextTrackShortcut,
        backgroundStyle: BackgroundStyle.values.firstWhere(
          (style) => style.name == decoded['backgroundStyle'],
          orElse: () => AppSettings.defaults.backgroundStyle,
        ),
        backgroundColorValue: savedBackground == previousDefaultAccent
            ? AppSettings.defaults.backgroundColorValue
            : savedBackground,
        wallpaperPath: decoded['wallpaperPath'] as String?,
        privateSession:
            decoded['privateSession'] as bool? ??
            AppSettings.defaults.privateSession,
        personalizedRecommendations:
            decoded['personalizedRecommendations'] as bool? ??
            AppSettings.defaults.personalizedRecommendations,
      );
    } catch (_) {
      state = AppSettings.defaults;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _settingsKey,
      jsonEncode({
        'themeMode': state.themeMode.name,
        'liquidGlass': state.liquidGlass,
        'uiScale': state.uiScale,
        'hardwareAcceleration': state.hardwareAcceleration,
        'amoledBlack': state.amoledBlack,
        'showGradient': state.showGradient,
        'accentColorValue': state.accentColorValue,
        'animationsEnabled': state.animationsEnabled,
        'adaptiveGlass': state.adaptiveGlass,
        'glassQuality': state.glassQuality.name,
        'glassSurfaceOpacity': state.glassSurfaceOpacity,
        'autoPlay': state.autoPlay,
        'crossfadeEnabled': state.crossfadeEnabled,
        'crossfadeDurationSeconds': state.crossfadeDurationSeconds,
        'highQualityAudio': state.highQualityAudio,
        'searchShowSongs': state.searchShowSongs,
        'searchShowPlaylists': state.searchShowPlaylists,
        'shuffle': state.shuffle,
        'repeatMode': state.repeatMode,
        'restoreLastTrack': state.restoreLastTrack,
        'miniPlayerShowShuffle': state.miniPlayerShowShuffle,
        'miniPlayerShowRepeat': state.miniPlayerShowRepeat,
        'miniPlayerShowQueue': state.miniPlayerShowQueue,
        'compactSidebar': state.compactSidebar,
        'sidebarShowTagline': state.sidebarShowTagline,
        'leftSidebarWidth': state.leftSidebarWidth,
        'rightSidebarWidth': state.rightSidebarWidth,
        'playPauseShortcut': state.playPauseShortcut,
        'seekBackwardShortcut': state.seekBackwardShortcut,
        'seekForwardShortcut': state.seekForwardShortcut,
        'previousTrackShortcut': state.previousTrackShortcut,
        'nextTrackShortcut': state.nextTrackShortcut,
        'backgroundStyle': state.backgroundStyle.name,
        'backgroundColorValue': state.backgroundColorValue,
        'wallpaperPath': state.wallpaperPath,
        'privateSession': state.privateSession,
        'personalizedRecommendations': state.personalizedRecommendations,
      }),
    );
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
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
    state = state.copyWith(showGradient: value);
    _persist();
  }

  void setShowGradient(bool value) {
    setBackgroundGradient(value);
  }

  void setAccentColor(int value) {
    state = state.copyWith(accentColorValue: value);
    _persist();
  }

  void setAnimationsEnabled(bool value) {
    state = state.copyWith(animationsEnabled: value);
    _persist();
  }

  void setAdaptiveGlass(bool value) {
    state = state.copyWith(adaptiveGlass: value);
    _persist();
  }

  void setGlassQuality(GlassQuality value) {
    state = state.copyWith(adaptiveGlass: false, glassQuality: value);
    _persist();
  }

  void setGlassSurfaceOpacity(double value) {
    state = state.copyWith(glassSurfaceOpacity: value);
    _persist();
  }

  void applyAdaptiveGlassScan(GlassQuality value) {
    state = state.copyWith(adaptiveGlass: true, glassQuality: value);
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

  void setCrossfadeEnabled(bool value) {
    state = state.copyWith(crossfadeEnabled: value);
    _persist();
  }

  void setCrossfadeDurationSeconds(int value) {
    state = state.copyWith(
      crossfadeDurationSeconds: value.clamp(1, 12).toInt(),
    );
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

  void setRestoreLastTrack(bool value) {
    state = state.copyWith(restoreLastTrack: value);
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

  void setLeftSidebarWidth(double value) {
    state = state.copyWith(leftSidebarWidth: value);
    _persist();
  }

  void setRightSidebarWidth(double value) {
    state = state.copyWith(rightSidebarWidth: value);
    _persist();
  }

  void setKeyboardShortcut(String action, String value) {
    state = switch (action) {
      'playPause' => state.copyWith(playPauseShortcut: value),
      'seekBackward' => state.copyWith(seekBackwardShortcut: value),
      'seekForward' => state.copyWith(seekForwardShortcut: value),
      'previousTrack' => state.copyWith(previousTrackShortcut: value),
      'nextTrack' => state.copyWith(nextTrackShortcut: value),
      _ => state,
    };
    _persist();
  }

  void setSidebarShowTagline(bool value) {
    state = state.copyWith(sidebarShowTagline: value);
    _persist();
  }

  void setPrivateSession(bool value) {
    state = state.copyWith(privateSession: value);
    _persist();
  }

  void setPersonalizedRecommendations(bool value) {
    state = state.copyWith(personalizedRecommendations: value);
    _persist();
  }

  void setBackgroundStyle(BackgroundStyle value) {
    state = state.copyWith(backgroundStyle: value);
    _persist();
  }

  void setBackgroundColor(int value) {
    state = state.copyWith(backgroundColorValue: value);
    _persist();
  }

  void setWallpaperPath(String? value) {
    state = state.copyWith(
      wallpaperPath: value,
      clearWallpaperPath: value == null,
    );
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
