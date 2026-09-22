import 'package:flutter/material.dart';

class AppSettings {
  static const _minUiScale = 0.9;
  static const _maxUiScale = 1.2;

  final ThemeMode themeMode;
  final bool liquidGlass;
  final double uiScale;
  final bool hardwareAcceleration;
  final bool autoPlay;
  final bool highQualityAudio;
  final double volumeBoost;

  const AppSettings({
    required this.themeMode,
    required this.liquidGlass,
    required this.uiScale,
    required this.hardwareAcceleration,
    this.autoPlay = true,
    this.highQualityAudio = true,
    this.volumeBoost = 80,
  });

  static double _clampUiScale(double value) {
    if (value.isNaN || value.isInfinite) {
      return 1.0;
    }

    return value.clamp(_minUiScale, _maxUiScale);
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? liquidGlass,
    double? uiScale,
    bool? hardwareAcceleration,
    bool? autoPlay,
    bool? highQualityAudio,
    double? volumeBoost,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      liquidGlass: liquidGlass ?? this.liquidGlass,
      uiScale: uiScale == null ? this.uiScale : _clampUiScale(uiScale),
      hardwareAcceleration:
          hardwareAcceleration ?? this.hardwareAcceleration,
        autoPlay: autoPlay ?? this.autoPlay,
        highQualityAudio: highQualityAudio ?? this.highQualityAudio,
        volumeBoost: volumeBoost == null
          ? this.volumeBoost
          : volumeBoost.clamp(0, 100),
    );
  }

  static const defaults = AppSettings(
    themeMode: ThemeMode.system,
    liquidGlass: true,
    uiScale: 1.0,
    hardwareAcceleration: true,
    autoPlay: true,
    highQualityAudio: true,
    volumeBoost: 80,
  );
}