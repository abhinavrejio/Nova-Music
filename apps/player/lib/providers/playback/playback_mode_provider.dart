import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlaybackRepeatMode {
  off,
  one,
  all,
}

class PlaybackModeNotifier extends Notifier<PlaybackRepeatMode> {
  static const _key = 'repeat_mode';
  int _revision = 0;

  @override
  PlaybackRepeatMode build() {
    _load();
    return PlaybackRepeatMode.off;
  }

  void nextMode() {
    switch (state) {
      case PlaybackRepeatMode.off:
        state = PlaybackRepeatMode.all;
        break;
      case PlaybackRepeatMode.all:
        state = PlaybackRepeatMode.one;
        break;
      case PlaybackRepeatMode.one:
        state = PlaybackRepeatMode.off;
        break;
    }
    _persist();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_key) ?? PlaybackRepeatMode.off.index;
    if (revision != _revision) return;
    if (stored >= 0 && stored < PlaybackRepeatMode.values.length) {
      state = PlaybackRepeatMode.values[stored];
    }
  }

  Future<void> _persist() async {
    _revision++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, state.index);
  }
}

final repeatModeProvider =
    NotifierProvider<PlaybackModeNotifier, PlaybackRepeatMode>(
  PlaybackModeNotifier.new,
);

class ShuffleNotifier extends Notifier<bool> {
  static const _key = 'shuffle_enabled';
  int _revision = 0;

  @override
  bool build() {
    _load();
    return false;
  }

  void toggle() {
    state = !state;
    _persist();
  }

  void enable() {
    state = true;
    _persist();
  }

  void disable() {
    state = false;
    _persist();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    final prefs = await SharedPreferences.getInstance();
    if (revision == _revision) {
      state = prefs.getBool(_key) ?? false;
    }
  }

  Future<void> _persist() async {
    _revision++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }
}

final shuffleProvider =
    NotifierProvider<ShuffleNotifier, bool>(
  ShuffleNotifier.new,
);