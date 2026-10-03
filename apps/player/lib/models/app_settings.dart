import 'package:flutter/material.dart';

class AppSettings {
  static const double minUiScale = 0.9;
  static const double maxUiScale = 1.2;

  // Appearance
  final ThemeMode themeMode;
  final bool liquidGlass;
  final double uiScale;
  final bool amoledBlack;
  final bool showGradient;
  final int accentColorValue;

  // Performance
  final bool hardwareAcceleration;

  // Audio
  final bool autoPlay;
  final bool highQualityAudio;

  // Search
  final bool searchShowSongs;
  final bool searchShowPlaylists;

  // Playback
  final bool shuffle;
  final int repeatMode;

  // Mini player
  final bool miniPlayerShowShuffle;
  final bool miniPlayerShowRepeat;
  final bool miniPlayerShowQueue;

  // Sidebar
  final bool compactSidebar;
  final bool sidebarShowTagline;

  const AppSettings({
    required this.themeMode,
    required this.liquidGlass,
    required this.uiScale,
    required this.hardwareAcceleration,

    this.amoledBlack = false,
    this.showGradient = true,
    this.accentColorValue = 0xFFFF6B5F,

    this.autoPlay = true,
    this.highQualityAudio = true,

    this.searchShowSongs = true,
    this.searchShowPlaylists = true,

    this.shuffle = false,
    this.repeatMode = 0,

    this.miniPlayerShowShuffle = true,
    this.miniPlayerShowRepeat = true,
    this.miniPlayerShowQueue = true,

    this.compactSidebar = false,
    this.sidebarShowTagline = true,
  });

  // Compatibility aliases.
  //
  // Some existing UI files use these names.
  bool get gradientBackground => showGradient;

  bool get backgroundGradient => showGradient;

  static double clampUiScale(double value) {
    if (value.isNaN || value.isInfinite) {
      return 1.0;
    }

    return value.clamp(minUiScale, maxUiScale).toDouble();
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? liquidGlass,
    double? uiScale,
    bool? hardwareAcceleration,

    bool? amoledBlack,
    bool? showGradient,
    int? accentColorValue,

    bool? autoPlay,
    bool? highQualityAudio,

    bool? searchShowSongs,
    bool? searchShowPlaylists,

    bool? shuffle,
    int? repeatMode,

    bool? miniPlayerShowShuffle,
    bool? miniPlayerShowRepeat,
    bool? miniPlayerShowQueue,

    bool? compactSidebar,
    bool? sidebarShowTagline,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      uiScale: uiScale == null
          ? this.uiScale
          : clampUiScale(uiScale),
      hardwareAcceleration:
          hardwareAcceleration ?? this.hardwareAcceleration,

      amoledBlack: amoledBlack ?? this.amoledBlack,
      showGradient: showGradient ?? this.showGradient,
      accentColorValue:
          accentColorValue ?? this.accentColorValue,

      autoPlay: autoPlay ?? this.autoPlay,
      highQualityAudio:
          highQualityAudio ?? this.highQualityAudio,

      searchShowSongs:
          searchShowSongs ?? this.searchShowSongs,
      searchShowPlaylists:
          searchShowPlaylists ?? this.searchShowPlaylists,

      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,

      miniPlayerShowShuffle:
          miniPlayerShowShuffle ??
          this.miniPlayerShowShuffle,
      miniPlayerShowRepeat:
          miniPlayerShowRepeat ??
          this.miniPlayerShowRepeat,
      miniPlayerShowQueue:
          miniPlayerShowQueue ??
          this.miniPlayerShowQueue,

      compactSidebar:
          compactSidebar ?? this.compactSidebar,
      sidebarShowTagline:
          sidebarShowTagline ?? this.sidebarShowTagline,
    );
  }

  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    liquidGlass: true,
    uiScale: 1.0,
    hardwareAcceleration: true,

    amoledBlack: false,
    showGradient: true,
    accentColorValue: 0xFFFF6B5F,

    autoPlay: true,
    highQualityAudio: true,

    searchShowSongs: true,
    searchShowPlaylists: true,

    shuffle: false,
    repeatMode: 0,

    miniPlayerShowShuffle: true,
    miniPlayerShowRepeat: true,
    miniPlayerShowQueue: true,

    compactSidebar: false,
    sidebarShowTagline: true,
  );
}