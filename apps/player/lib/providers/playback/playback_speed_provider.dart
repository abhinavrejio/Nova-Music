import 'package:flutter_riverpod/flutter_riverpod.dart';

final playbackSpeedProvider = NotifierProvider<PlaybackSpeedNotifier, double>(
  PlaybackSpeedNotifier.new,
);

class PlaybackSpeedNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  void setSpeed(double speed) {
    state = speed;
  }
}
