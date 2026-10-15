import 'package:flutter/material.dart';

enum GlassQuality { low, balanced, high }

enum BackgroundStyle { gradient, albumArtwork, wallpaper, solidColor }

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
  final bool animationsEnabled;
  final bool adaptiveGlass;
  final GlassQuality glassQuality;

  // Kept for backwards compatibility with saved settings and callers.
  final bool hardwareAcceleration;

  // Audio
  final bool autoPlay;
  final bool crossfadeEnabled;
  final int crossfadeDurationSeconds;
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
  final BackgroundStyle backgroundStyle;
  final int backgroundColorValue;
  final String? wallpaperPath;

  const AppSettings({
    required this.themeMode,
    required this.liquidGlass,
    required this.uiScale,
    this.hardwareAcceleration = true,
    this.amoledBlack = false,
    this.showGradient = true,
    this.accentColorValue = 0xFFFF6B5F,
    this.animationsEnabled = true,
    this.adaptiveGlass = true,
    this.glassQuality = GlassQuality.balanced,
    this.autoPlay = true,
    this.crossfadeEnabled = false,
    this.crossfadeDurationSeconds = 5,
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
    this.backgroundStyle = BackgroundStyle.gradient,
    this.backgroundColorValue = 0xFFFF6B5F,
    this.wallpaperPath,
  });

  bool get gradientBackground => showGradient;
  bool get backgroundGradient => showGradient;
  double get glassBlurSigma => switch (glassQuality) {
    GlassQuality.low => 8,
    GlassQuality.balanced => 18,
    GlassQuality.high => 28,
  };
  double get glassSurfaceOpacity => switch (glassQuality) {
    GlassQuality.low => .78,
    GlassQuality.balanced => .64,
    GlassQuality.high => .52,
  };

  static double clampUiScale(double value) {
    if (value.isNaN || value.isInfinite) return 1.0;
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
    bool? animationsEnabled,
    bool? adaptiveGlass,
    GlassQuality? glassQuality,
    bool? autoPlay,
    bool? crossfadeEnabled,
    int? crossfadeDurationSeconds,
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
    BackgroundStyle? backgroundStyle,
    int? backgroundColorValue,
    String? wallpaperPath,
    bool clearWallpaperPath = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      uiScale: uiScale == null ? this.uiScale : clampUiScale(uiScale),
      hardwareAcceleration: hardwareAcceleration ?? this.hardwareAcceleration,
      amoledBlack: amoledBlack ?? this.amoledBlack,
      showGradient: showGradient ?? this.showGradient,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      adaptiveGlass: adaptiveGlass ?? this.adaptiveGlass,
      glassQuality: glassQuality ?? this.glassQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDurationSeconds: crossfadeDurationSeconds == null
          ? this.crossfadeDurationSeconds.clamp(1, 12).toInt()
          : crossfadeDurationSeconds.clamp(1, 12).toInt(),
      highQualityAudio: highQualityAudio ?? this.highQualityAudio,
      searchShowSongs: searchShowSongs ?? this.searchShowSongs,
      searchShowPlaylists: searchShowPlaylists ?? this.searchShowPlaylists,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      miniPlayerShowShuffle:
          miniPlayerShowShuffle ?? this.miniPlayerShowShuffle,
      miniPlayerShowRepeat: miniPlayerShowRepeat ?? this.miniPlayerShowRepeat,
      miniPlayerShowQueue: miniPlayerShowQueue ?? this.miniPlayerShowQueue,
      compactSidebar: compactSidebar ?? this.compactSidebar,
      sidebarShowTagline: sidebarShowTagline ?? this.sidebarShowTagline,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      wallpaperPath: clearWallpaperPath
          ? null
          : wallpaperPath ?? this.wallpaperPath,
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
    animationsEnabled: true,
    adaptiveGlass: true,
    glassQuality: GlassQuality.balanced,
    autoPlay: true,
    crossfadeEnabled: false,
    crossfadeDurationSeconds: 5,
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
    backgroundStyle: BackgroundStyle.gradient,
    backgroundColorValue: 0xFFFF6B5F,
  );
}
