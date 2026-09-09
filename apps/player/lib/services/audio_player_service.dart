import 'package:media_kit/media_kit.dart';

class AudioPlayerService {
  AudioPlayerService();

  final Player _player = Player();

  Player get player => _player;

  // ---------------------------------------------------------------------------
  // Open
  // ---------------------------------------------------------------------------

  Future<void> openFile(String path) async {
    await _player.open(
      Media(path),
      play: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> togglePlayPause() async {
    if (_player.state.playing) {
      await pause();
    } else {
      await play();
    }
  }

  // ---------------------------------------------------------------------------
  // Seeking
  // ---------------------------------------------------------------------------

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  Stream<bool> get playingStream => _player.stream.playing;

  Stream<Duration> get positionStream => _player.stream.position;

  Stream<Duration> get durationStream => _player.stream.duration;

  Stream<Duration> get bufferStream => _player.stream.buffer;

  Stream<bool> get completedStream => _player.stream.completed;

  // ---------------------------------------------------------------------------
  // Current State
  // ---------------------------------------------------------------------------

  bool get isPlaying => _player.state.playing;

  Duration get position => _player.state.position;

  Duration get duration => _player.state.duration;

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    await _player.dispose();
  }
}