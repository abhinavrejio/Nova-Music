import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';
import 'audio_state.dart';

class AudioController extends Notifier<AudioState> {
  final AudioService _service = AudioService.instance;

  @override
  AudioState build() {
    return const AudioState();
  }

  Future<void> play() async {
    await _service.play();

    state = state.copyWith(
      status: PlaybackStatus.playing,
    );
  }

  Future<void> pause() async {
    await _service.pause();

    state = state.copyWith(
      status: PlaybackStatus.paused,
    );
  }

  Future<void> stop() async {
    await _service.stop();

    state = state.copyWith(
      status: PlaybackStatus.stopped,
    );
  }

  Future<void> loadSong({
    required String path,
    required String title,
    required String artist,
    String album = '',
  }) async {
    await _service.loadFile(path);

    state = state.copyWith(
      title: title,
      artist: artist,
      album: album,
      status: PlaybackStatus.paused,
    );
  }

  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);

    state = state.copyWith(
      volume: volume,
    );
  }
}