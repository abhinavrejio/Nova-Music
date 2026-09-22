import 'dart:io';

import 'package:media_kit/media_kit.dart';

class AudioPlayerService {
  AudioPlayerService() {
    final isTestEnvironment = Platform.environment.containsKey('FLUTTER_TEST');

    if (isTestEnvironment) {
      _mediaKitReady = false;
      return;
    }

    try {
      MediaKit.ensureInitialized();
      _mediaKitReady = true;
    } catch (_) {
      _mediaKitReady = false;
    }
  }

  bool _mediaKitReady = false;
  Player? _player;

  Player get player {
    if (!_mediaKitReady) {
      throw StateError('MediaKit is unavailable in this environment.');
    }

    _player ??= Player();
    return _player!;
  }

  // ---------------------------------------------------------------------------
  // Open
  // ---------------------------------------------------------------------------

  Future<void> openFile(String path, {bool play = true}) async {
    if (!_mediaKitReady || path.isEmpty) {
      return;
    }

    try {
      await player.open(
        Media(path),
        play: play,
      );
    } catch (_) {
      // Ignore unsupported native playback environments like widget tests.
    }
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> play() async {
    if (!_mediaKitReady) return;
    try {
      await player.play();
    } catch (_) {}
  }

  Future<void> pause() async {
    if (!_mediaKitReady) return;
    try {
      await player.pause();
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    if (!_mediaKitReady || _player == null) return;
    try {
      await _player!.setVolume(volume);
    } catch (_) {}
  }

  Future<void> setRate(double rate) async {
    if (!_mediaKitReady || _player == null) return;
    try {
      await _player!.setRate(rate);
    } catch (_) {}
  }

  Future<void> stop() async {
    if (!_mediaKitReady) return;
    try {
      await player.stop();
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (!_mediaKitReady || _player == null) return;
    try {
      if (player.state.playing) {
        await pause();
      } else {
        await play();
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Seeking
  // ---------------------------------------------------------------------------

  Future<void> seek(Duration position) async {
    if (!_mediaKitReady || _player == null) return;
    try {
      await _player!.seek(position);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  Stream<bool> get playingStream => _player?.stream.playing ?? const Stream.empty();

  Stream<Duration> get positionStream => _player?.stream.position ?? const Stream.empty();

  Stream<Duration> get durationStream => _player?.stream.duration ?? const Stream.empty();

  Stream<Duration> get bufferStream => _player?.stream.buffer ?? const Stream.empty();

  Stream<bool> get completedStream => _player?.stream.completed ?? const Stream.empty();

  // ---------------------------------------------------------------------------
  // Current State
  // ---------------------------------------------------------------------------

  bool get isPlaying => _player?.state.playing ?? false;

  Duration get position => _player?.state.position ?? Duration.zero;

  Duration get duration => _player?.state.duration ?? Duration.zero;

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    if (_player == null) return;
    try {
      await _player!.dispose();
    } catch (_) {}
  }
}