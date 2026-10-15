import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/current_song.dart';
import '../audio/audio_player_provider.dart';
import 'current_song_provider.dart';
import 'queue_provider.dart';
import 'queue_index_provider.dart';
import 'playback_mode_provider.dart';
import '../settings_provider.dart';

class PlaybackController {
  PlaybackController(this.ref);

  final Ref ref;

  StreamSubscription<bool>? _completedSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  bool _crossfadeStarted = false;

  /// Start listening for song completion.
  void startListening() {
    _completedSubscription?.cancel();

    final service = ref.read(audioPlayerProvider);
    if (!service.isReady) {
      return;
    }

    _completedSubscription = service.completedStream.listen(
      (completed) async {
        if (!completed) {
          return;
        }

        if (!ref.read(settingsProvider).autoPlay) {
          return;
        }

        await next(fromCompletion: true);
      },
    );

    _positionSubscription = service.positionStream.listen((position) {
      _maybeStartCrossfade(position);
    });
  }

  void _maybeStartCrossfade(Duration position) {
    final settings = ref.read(settingsProvider);
    if (!settings.autoPlay || !settings.crossfadeEnabled || _crossfadeStarted) {
      return;
    }

    final repeatMode = ref.read(repeatModeProvider);
    if (repeatMode == PlaybackRepeatMode.one) return;

    final service = ref.read(audioPlayerProvider);
    final duration = service.duration;
    if (duration <= Duration.zero || position < Duration.zero) return;

    final fadeDuration = Duration(seconds: settings.crossfadeDurationSeconds);
    final remaining = duration - position;
    if (remaining > fadeDuration || remaining <= Duration.zero) return;

    final queue = ref.read(queueProvider);
    if (queue.isEmpty) return;

    final current = ref.read(queueIndexProvider);
    final nextIndex = _nextIndex(
      queueLength: queue.length,
      current: current,
      shuffle: ref.read(shuffleProvider),
      repeatMode: repeatMode,
    );
    if (nextIndex == null) return;

    _crossfadeStarted = true;
    final nextSong = queue[nextIndex];
    ref.read(queueIndexProvider.notifier).setIndex(nextIndex);
    ref.read(currentSongProvider.notifier).setSong(nextSong);

    unawaited(
      service
          .crossfadeTo(
            nextSong.path,
            duration: fadeDuration < remaining ? fadeDuration : remaining,
          )
          .then(
            (_) => _crossfadeStarted = false,
            onError: (Object _, StackTrace __) {
              _crossfadeStarted = false;
            },
          ),
    );
  }

  int? _nextIndex({
    required int queueLength,
    required int current,
    required bool shuffle,
    required PlaybackRepeatMode repeatMode,
  }) {
    if (queueLength == 0) return null;
    if (repeatMode == PlaybackRepeatMode.one) return current;

    if (shuffle) {
      if (queueLength == 1) return 0;
      var next = DateTime.now().millisecondsSinceEpoch % queueLength;
      while (next == current) {
        next = (next + 1) % queueLength;
      }
      return next;
    }

    if (current < queueLength - 1) return current + 1;
    if (repeatMode == PlaybackRepeatMode.all) return 0;
    return null;
  }

  /// Play a specific song.
  Future<void> playSong(CurrentSong song, int index) async {
    ref.read(queueIndexProvider.notifier).setIndex(index);
    ref.read(currentSongProvider.notifier).setSong(song);

    await ref.read(audioPlayerProvider).openFile(
      song.path,
      play: ref.read(settingsProvider).autoPlay,
    );
  }

  /// Play the next song.
  Future<void> next({bool fromCompletion = false}) async {
    if (fromCompletion && !ref.read(settingsProvider).autoPlay) {
      return;
    }

    final queue = ref.read(queueProvider);

    if (queue.isEmpty) return;

    final repeatMode = ref.read(repeatModeProvider);
    final current = ref.read(queueIndexProvider);

    if (fromCompletion && repeatMode == PlaybackRepeatMode.one) {
      final currentSong = queue[current];
      await ref.read(audioPlayerProvider).openFile(
        currentSong.path,
        play: ref.read(settingsProvider).autoPlay,
      );
      return;
    }

    final nextIndex = _nextIndex(
      queueLength: queue.length,
      current: current,
      shuffle: ref.read(shuffleProvider),
      repeatMode: repeatMode,
    );
    if (nextIndex == null) return;

    final nextSong = queue[nextIndex];

    ref.read(queueIndexProvider.notifier).setIndex(nextIndex);
    ref.read(currentSongProvider.notifier).setSong(nextSong);

    await ref.read(audioPlayerProvider).openFile(
      nextSong.path,
      play: ref.read(settingsProvider).autoPlay,
    );
  }

  /// Play the previous song.
  Future<void> previous() async {
    final queue = ref.read(queueProvider);
    final index = ref.read(queueIndexProvider);

    if (queue.isEmpty) return;

    if (index <= 0) {
      return;
    }

    final previousIndex = index - 1;
    final previousSong = queue[previousIndex];

    ref.read(queueIndexProvider.notifier).setIndex(previousIndex);
    ref.read(currentSongProvider.notifier).setSong(previousSong);

    await ref.read(audioPlayerProvider).openFile(previousSong.path);
  }

  void dispose() {
    _completedSubscription?.cancel();
    _positionSubscription?.cancel();
  }
}
final playbackControllerProvider = Provider<PlaybackController>((ref) {
  final controller = PlaybackController(ref);
  controller.startListening();
  ref.onDispose(controller.dispose);
  return controller;
});