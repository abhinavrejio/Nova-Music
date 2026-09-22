import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/audio_player_provider.dart';

final sleepTimerProvider = NotifierProvider<SleepTimerNotifier, Duration?>(
  SleepTimerNotifier.new,
);

class SleepTimerNotifier extends Notifier<Duration?> {
  Timer? _timer;

  @override
  Duration? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void setTimer(Duration? duration) {
    _timer?.cancel();
    _timer = null;
    state = duration;

    if (duration == null) return;
    _timer = Timer(duration, () async {
      await ref.read(audioPlayerProvider).stop();
      state = null;
      _timer = null;
    });
  }
}
