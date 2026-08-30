import 'package:media_kit/media_kit.dart';

class AudioPlayerService {
  AudioPlayerService();

  final Player _player = Player();

  Player get player => _player;

  // -------------------------
  // Playback
  // -------------------------

  Future<void> openFile(String path) async {
    await _player.open(
      Media(path),
      play: true,
    );
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.state.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // -------------------------
  // Streams
  // -------------------------

  Stream<bool> get playingStream => _player.stream.playing;

  Stream<Duration> get positionStream => _player.stream.position;

  Stream<Duration> get durationStream => _player.stream.duration;

  // -------------------------
  // Current State
  // -------------------------

  bool get isPlaying => _player.state.playing;

  Duration get position => _player.state.position;

  Duration get duration => _player.state.duration;

  // -------------------------
  // Dispose
  // -------------------------

  Future<void> dispose() async {
    await _player.dispose();
  }
}