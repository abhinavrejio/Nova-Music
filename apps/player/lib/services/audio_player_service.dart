import 'dart:async';
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
  Player? _secondaryPlayer;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _bufferSubscription;
  StreamSubscription<bool>? _completedSubscription;
  Timer? _crossfadeTimer;
  bool _crossfading = false;
  double _volume = 100;

  final _playingController = StreamController<bool>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _bufferController = StreamController<Duration>.broadcast();
  final _completedController = StreamController<bool>.broadcast();

  bool get isReady => _mediaKitReady;
  double get volume => _volume;

  Player get player {
    if (!_mediaKitReady) {
      throw StateError('MediaKit is unavailable in this environment.');
    }
    return _ensurePrimary();
  }

  Player _ensurePrimary() {
    _player ??= Player();
    _wireActivePlayer(_player!);
    return _player!;
  }

  void _wireActivePlayer(Player activePlayer) {
    if (_playingSubscription != null) return;

    _playingSubscription = activePlayer.stream.playing.listen((_) {
      _publishPlayingState();
    });
    _positionSubscription = activePlayer.stream.position.listen(
      _positionController.add,
    );
    _durationSubscription = activePlayer.stream.duration.listen(
      _durationController.add,
    );
    _bufferSubscription = activePlayer.stream.buffer.listen(
      _bufferController.add,
    );
    _completedSubscription = activePlayer.stream.completed.listen((completed) {
      if (!_crossfading && activePlayer == _player) {
        _completedController.add(completed);
      }
    });
  }

  void _publishPlayingState() {
    _playingController.add(isPlaying);
  }

  Future<void> _rewireActivePlayer() async {
    await _cancelActiveSubscriptions();
    if (_player != null) {
      _wireActivePlayer(_player!);
    }
  }

  Future<void> _cancelActiveSubscriptions() async {
    await _playingSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _bufferSubscription?.cancel();
    await _completedSubscription?.cancel();
    _playingSubscription = null;
    _positionSubscription = null;
    _durationSubscription = null;
    _bufferSubscription = null;
    _completedSubscription = null;
  }

  // ---------------------------------------------------------------------------
  // Open
  // ---------------------------------------------------------------------------

  Future<void> openFile(String path, {bool play = true}) async {
    if (!_mediaKitReady || path.isEmpty) return;

    try {
      _crossfadeTimer?.cancel();
      _crossfadeTimer = null;
      _crossfading = false;

      final secondary = _secondaryPlayer;
      _secondaryPlayer = null;
      if (secondary != null) {
        await secondary.stop();
        await secondary.dispose();
      }

      final active = _ensurePrimary();
      await active.setVolume(_volume);
      await active.open(Media(path), play: play);
    } catch (_) {
      // Ignore unsupported native playback environments.
    }
  }

  /// Crossfades from the currently active player into [path].
  ///
  /// Two media players are used only for the overlap window. The normal
  /// single-player path remains unchanged when crossfade is disabled.
  Future<void> crossfadeTo(String path, {required Duration duration}) async {
    if (!_mediaKitReady || path.isEmpty || _crossfading) return;

    final active = _ensurePrimary();
    if (!active.state.playing) {
      await openFile(path);
      return;
    }

    final fade = duration <= Duration.zero ? Duration.zero : duration;
    if (fade == Duration.zero) {
      await openFile(path);
      return;
    }

    _crossfading = true;
    final completion = Completer<void>();

    try {
      final next = Player();
      _secondaryPlayer = next;
      await next.setVolume(0);
      await next.open(Media(path), play: true);
      _publishPlayingState();

      final started = DateTime.now();
      const interval = Duration(milliseconds: 40);

      Future<void> tick() async {
        if (!_crossfading || _secondaryPlayer != next) {
          if (!completion.isCompleted) completion.complete();
          return;
        }

        try {
          final elapsed = DateTime.now().difference(started);
          final progress = (elapsed.inMicroseconds / fade.inMicroseconds)
              .clamp(0.0, 1.0)
              .toDouble();

          await active.setVolume(_volume * (1.0 - progress));
          await next.setVolume(_volume * progress);

          if (progress >= 1.0) {
            await _finishCrossfade(active, next);
            if (!completion.isCompleted) completion.complete();
          } else {
            _crossfadeTimer = Timer(interval, tick);
          }
        } catch (error, stackTrace) {
          _crossfadeTimer?.cancel();
          _crossfadeTimer = null;
          _crossfading = false;
          await active.setVolume(_volume);
          await nextSafeDispose();
          if (!completion.isCompleted) {
            completion.completeError(error, stackTrace);
          }
        }
      }

      _crossfadeTimer = Timer(interval, tick);
      await completion.future;
    } catch (error, stackTrace) {
      _crossfadeTimer?.cancel();
      _crossfadeTimer = null;
      _crossfading = false;
      await active.setVolume(_volume);
      await nextSafeDispose();
      if (!completion.isCompleted) {
        completion.completeError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> _finishCrossfade(Player oldPlayer, Player nextPlayer) async {
    if (_secondaryPlayer != nextPlayer) return;

    _crossfadeTimer?.cancel();
    _crossfadeTimer = null;

    await nextPlayer.setVolume(_volume);
    await oldPlayer.stop();
    await oldPlayer.dispose();

    _player = nextPlayer;
    _secondaryPlayer = null;
    _crossfading = false;
    await _rewireActivePlayer();
  }

  Future<void> nextSafeDispose() async {
    final secondary = _secondaryPlayer;
    _secondaryPlayer = null;
    if (secondary != null) {
      try {
        await secondary.stop();
        await secondary.dispose();
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------------

  Future<void> play() async {
    if (!_mediaKitReady) return;
    try {
      await _ensurePrimary().play();
      if (_crossfading) await _secondaryPlayer?.play();
      _publishPlayingState();
    } catch (_) {}
  }

  Future<void> pause() async {
    if (!_mediaKitReady) return;
    try {
      await _ensurePrimary().pause();
      if (_crossfading) await _secondaryPlayer?.pause();
      _publishPlayingState();
    } catch (_) {}
  }

  Future<void> setVolume(double volume) async {
    if (!_mediaKitReady) return;
    _volume = volume.clamp(0, 100).toDouble();
    try {
      await _ensurePrimary().setVolume(_volume);
    } catch (_) {}
  }

  Future<void> setRate(double rate) async {
    if (!_mediaKitReady || _player == null) return;
    try {
      await _player!.setRate(rate);
      if (_secondaryPlayer != null) {
        await _secondaryPlayer!.setRate(rate);
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    if (!_mediaKitReady) return;
    try {
      _crossfadeTimer?.cancel();
      _crossfading = false;
      await _ensurePrimary().stop();
      await nextSafeDispose();
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (!_mediaKitReady || _player == null) return;
    try {
      if (isPlaying) {
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

  Stream<bool> get playingStream => _playingController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<Duration> get bufferStream => _bufferController.stream;
  Stream<bool> get completedStream => _completedController.stream;

  // ---------------------------------------------------------------------------
  // Current State
  // ---------------------------------------------------------------------------

  bool get isPlaying =>
      (_player?.state.playing ?? false) ||
      (_crossfading && (_secondaryPlayer?.state.playing ?? false));
  Duration get position => _player?.state.position ?? Duration.zero;
  Duration get duration => _player?.state.duration ?? Duration.zero;

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    _crossfadeTimer?.cancel();
    _crossfadeTimer = null;
    _crossfading = false;
    await _cancelActiveSubscriptions();

    try {
      await _player?.dispose();
    } catch (_) {}
    try {
      await _secondaryPlayer?.dispose();
    } catch (_) {}

    _player = null;
    _secondaryPlayer = null;
    await _playingController.close();
    await _positionController.close();
    await _durationController.close();
    await _bufferController.close();
    await _completedController.close();
  }
}
