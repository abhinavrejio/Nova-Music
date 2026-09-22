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

  /// Start listening for song completion.
  void startListening() {
    _completedSubscription?.cancel();

    final player = ref.read(audioPlayerProvider).player;

    _completedSubscription = player.stream.completed.listen(
      (completed) async {
        if (completed) {
          await next(fromCompletion: true);
        }
      },
    );
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

    final shuffle = ref.read(shuffleProvider);
    int nextIndex;

    if (shuffle) {
      if (queue.length == 1) {
        nextIndex = 0;
      } else {
        do {
          nextIndex = DateTime.now().millisecondsSinceEpoch % queue.length;
        } while (nextIndex == current);
      }
    } else {
      if (current >= queue.length - 1) {
        if (fromCompletion && repeatMode == PlaybackRepeatMode.all) {
          nextIndex = 0;
        } else {
          return;
        }
      } else {
        nextIndex = current + 1;
      }
    }

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
  }
}
final playbackControllerProvider = Provider<PlaybackController>(
  (ref) => PlaybackController(ref),
);