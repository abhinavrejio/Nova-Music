import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  final SettingsService _service = SettingsService();

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    state = await _service.load();
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    await _service.save(settings);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);