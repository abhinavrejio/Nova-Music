import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const _syncKey = "syncLibrary";
  static const _historyKey = "history";
  static const _glassKey = "glass";
  static const _hardwareKey = "hardwareAcceleration";
  static const _themeKey = "theme";

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return AppSettings(
      syncLibrary: prefs.getBool(_syncKey) ?? true,
      listeningHistory: prefs.getBool(_historyKey) ?? true,
      liquidGlass: prefs.getBool(_glassKey) ?? true,
      hardwareAcceleration:
          prefs.getBool(_hardwareKey) ?? true,
      themeMode: AppThemeMode.values.firstWhere(
        (e) =>
            e.name ==
            (prefs.getString(_themeKey) ?? "system"),
      ),
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _syncKey,
      settings.syncLibrary,
    );

    await prefs.setBool(
      _historyKey,
      settings.listeningHistory,
    );

    await prefs.setBool(
      _glassKey,
      settings.liquidGlass,
    );

    await prefs.setBool(
      _hardwareKey,
      settings.hardwareAcceleration,
    );

    await prefs.setString(
      _themeKey,
      settings.themeMode.name,
    );
  }
}