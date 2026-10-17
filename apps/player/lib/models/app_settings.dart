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
  final double glassSurfaceOpacity;

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
  final bool restoreLastTrack;

  // Mini player
  final bool miniPlayerShowShuffle;
  final bool miniPlayerShowRepeat;
  final bool miniPlayerShowQueue;

  // Sidebar
  final bool compactSidebar;
  final bool sidebarShowTagline;
  final double leftSidebarWidth;
  final double rightSidebarWidth;

  // Keyboard shortcuts are stored as normalized combinations such as
  // `space` or `ctrl+arrowright` so they can be edited without code changes.
  final String playPauseShortcut;
  final String seekBackwardShortcut;
  final String seekForwardShortcut;
  final String previousTrackShortcut;
  final String nextTrackShortcut;
  final BackgroundStyle backgroundStyle;
  final int backgroundColorValue;
  final String? wallpaperPath;

  // Privacy
  final bool privateSession;
  final bool personalizedRecommendations;

  const AppSettings({
    required this.themeMode,
    required this.liquidGlass,
    required this.uiScale,
    this.hardwareAcceleration = true,
    this.amoledBlack = false,
    this.showGradient = true,
    this.accentColorValue = 0xFFDF6B3E,
    this.animationsEnabled = true,
    this.adaptiveGlass = true,
    this.glassQuality = GlassQuality.balanced,
    this.glassSurfaceOpacity = .64,
    this.autoPlay = true,
    this.crossfadeEnabled = false,
    this.crossfadeDurationSeconds = 5,
    this.highQualityAudio = true,
    this.searchShowSongs = true,
    this.searchShowPlaylists = true,
    this.shuffle = false,
    this.repeatMode = 0,
    this.restoreLastTrack = false,
    this.miniPlayerShowShuffle = true,
    this.miniPlayerShowRepeat = true,
    this.miniPlayerShowQueue = true,
    this.compactSidebar = false,
    this.sidebarShowTagline = true,
    this.leftSidebarWidth = 264,
    this.rightSidebarWidth = 320,
    this.playPauseShortcut = 'space',
    this.seekBackwardShortcut = 'arrowleft',
    this.seekForwardShortcut = 'arrowright',
    this.previousTrackShortcut = 'ctrl+arrowleft',
    this.nextTrackShortcut = 'ctrl+arrowright',
    this.backgroundStyle = BackgroundStyle.albumArtwork,
    this.backgroundColorValue = 0xFFDF6B3E,
    this.wallpaperPath,
    this.privateSession = false,
    this.personalizedRecommendations = true,
  });

  bool get gradientBackground => showGradient;
  bool get backgroundGradient => showGradient;
  double get glassBlurSigma => switch (glassQuality) {
    GlassQuality.low => 8,
    GlassQuality.balanced => 18,
    GlassQuality.high => 28,
  };
  static double clampGlassSurfaceOpacity(double value) {
    if (value.isNaN || value.isInfinite) return .64;
    return value.clamp(.42, .88).toDouble();
  }

  static double clampUiScale(double value) {
    if (value.isNaN || value.isInfinite) return 1.0;
    return value.clamp(minUiScale, maxUiScale).toDouble();
  }

  static double clampLeftSidebarWidth(double value) {
    if (value.isNaN || value.isInfinite) return 264;
    return value.clamp(208, 380).toDouble();
  }

  static double clampRightSidebarWidth(double value) {
    if (value.isNaN || value.isInfinite) return 320;
    return value.clamp(260, 440).toDouble();
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
    double? glassSurfaceOpacity,
    bool? autoPlay,
    bool? crossfadeEnabled,
    int? crossfadeDurationSeconds,
    bool? highQualityAudio,
    bool? searchShowSongs,
    bool? searchShowPlaylists,
    bool? shuffle,
    int? repeatMode,
    bool? restoreLastTrack,
    bool? miniPlayerShowShuffle,
    bool? miniPlayerShowRepeat,
    bool? miniPlayerShowQueue,
    bool? compactSidebar,
    bool? sidebarShowTagline,
    double? leftSidebarWidth,
    double? rightSidebarWidth,
    String? playPauseShortcut,
    String? seekBackwardShortcut,
    String? seekForwardShortcut,
    String? previousTrackShortcut,
    String? nextTrackShortcut,
    BackgroundStyle? backgroundStyle,
    int? backgroundColorValue,
    String? wallpaperPath,
    bool clearWallpaperPath = false,
    bool? privateSession,
    bool? personalizedRecommendations,
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
      glassSurfaceOpacity: glassSurfaceOpacity == null
          ? this.glassSurfaceOpacity
          : clampGlassSurfaceOpacity(glassSurfaceOpacity),
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
      restoreLastTrack: restoreLastTrack ?? this.restoreLastTrack,
      miniPlayerShowShuffle:
          miniPlayerShowShuffle ?? this.miniPlayerShowShuffle,
      miniPlayerShowRepeat: miniPlayerShowRepeat ?? this.miniPlayerShowRepeat,
      miniPlayerShowQueue: miniPlayerShowQueue ?? this.miniPlayerShowQueue,
      compactSidebar: compactSidebar ?? this.compactSidebar,
      sidebarShowTagline: sidebarShowTagline ?? this.sidebarShowTagline,
      leftSidebarWidth: leftSidebarWidth == null
          ? this.leftSidebarWidth
          : clampLeftSidebarWidth(leftSidebarWidth),
      rightSidebarWidth: rightSidebarWidth == null
          ? this.rightSidebarWidth
          : clampRightSidebarWidth(rightSidebarWidth),
      playPauseShortcut: playPauseShortcut ?? this.playPauseShortcut,
      seekBackwardShortcut: seekBackwardShortcut ?? this.seekBackwardShortcut,
      seekForwardShortcut: seekForwardShortcut ?? this.seekForwardShortcut,
      previousTrackShortcut:
          previousTrackShortcut ?? this.previousTrackShortcut,
      nextTrackShortcut: nextTrackShortcut ?? this.nextTrackShortcut,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
      wallpaperPath: clearWallpaperPath
          ? null
          : wallpaperPath ?? this.wallpaperPath,
      privateSession: privateSession ?? this.privateSession,
      personalizedRecommendations:
          personalizedRecommendations ?? this.personalizedRecommendations,
    );
  }

  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    liquidGlass: true,
    uiScale: 1.0,
    hardwareAcceleration: true,
    amoledBlack: false,
    showGradient: true,
    accentColorValue: 0xFFDF6B3E,
    animationsEnabled: true,
    adaptiveGlass: true,
    glassQuality: GlassQuality.balanced,
    glassSurfaceOpacity: .64,
    autoPlay: true,
    crossfadeEnabled: false,
    crossfadeDurationSeconds: 5,
    highQualityAudio: true,
    searchShowSongs: true,
    searchShowPlaylists: true,
    shuffle: false,
    repeatMode: 0,
    restoreLastTrack: false,
    miniPlayerShowShuffle: true,
    miniPlayerShowRepeat: true,
    miniPlayerShowQueue: true,
    compactSidebar: false,
    sidebarShowTagline: true,
    backgroundStyle: BackgroundStyle.albumArtwork,
    backgroundColorValue: 0xFFDF6B3E,
  );
}
