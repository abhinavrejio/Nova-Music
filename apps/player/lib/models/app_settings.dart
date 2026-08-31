enum AppThemeMode {
  system,
  light,
  dark,
}

class AppSettings {
  final bool syncLibrary;
  final bool listeningHistory;
  final bool liquidGlass;
  final bool hardwareAcceleration;

  final AppThemeMode themeMode;

  const AppSettings({
    this.syncLibrary = true,
    this.listeningHistory = true,
    this.liquidGlass = true,
    this.hardwareAcceleration = true,
    this.themeMode = AppThemeMode.system,
  });

  AppSettings copyWith({
    bool? syncLibrary,
    bool? listeningHistory,
    bool? liquidGlass,
    bool? hardwareAcceleration,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      syncLibrary: syncLibrary ?? this.syncLibrary,
      listeningHistory:
          listeningHistory ?? this.listeningHistory,
      liquidGlass:
          liquidGlass ?? this.liquidGlass,
      hardwareAcceleration:
          hardwareAcceleration ??
          this.hardwareAcceleration,
      themeMode:
          themeMode ?? this.themeMode,
    );
  }
}