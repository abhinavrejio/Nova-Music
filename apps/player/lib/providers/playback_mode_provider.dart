import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlaybackRepeatMode {
  off,
  one,
  all,
}

class PlaybackModeNotifier extends Notifier<PlaybackRepeatMode> {
  @override
  PlaybackRepeatMode build() => PlaybackRepeatMode.off;

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
  }
}

final repeatModeProvider =
    NotifierProvider<PlaybackModeNotifier, PlaybackRepeatMode>(
  PlaybackModeNotifier.new,
);

class ShuffleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void enable() {
    state = true;
  }

  void disable() {
    state = false;
  }
}

final shuffleProvider =
    NotifierProvider<ShuffleNotifier, bool>(
  ShuffleNotifier.new,
);