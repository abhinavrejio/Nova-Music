import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio/audio_player_provider.dart';
import '../providers/playback/current_song_provider.dart';
import '../providers/playback/queue_provider.dart';
import '../providers/playback/queue_index_provider.dart';

class PlaybackController {
  PlaybackController(this.ref);

  final Ref ref;

  Future<void> next() async {
    final queue = ref.read(queueProvider);
    final index = ref.read(queueIndexProvider);

    if (queue.isEmpty) return;
    if (index >= queue.length - 1) return;

    final nextIndex = index + 1;
    final song = queue[nextIndex];

    ref.read(queueIndexProvider.notifier).setIndex(nextIndex);
    ref.read(currentSongProvider.notifier).setSong(song);

    await ref.read(audioPlayerProvider).openFile(song.path);
  }

  Future<void> previous() async {
    final queue = ref.read(queueProvider);
    final index = ref.read(queueIndexProvider);

    if (queue.isEmpty) return;
    if (index <= 0) return;

    final previousIndex = index - 1;
    final song = queue[previousIndex];

    ref.read(queueIndexProvider.notifier).setIndex(previousIndex);
    ref.read(currentSongProvider.notifier).setSong(song);

    await ref.read(audioPlayerProvider).openFile(song.path);
  }
}