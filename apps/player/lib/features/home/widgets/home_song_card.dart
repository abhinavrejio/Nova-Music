import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../player/player_page.dart';

class HomeSongCard extends ConsumerWidget {
  const HomeSongCard({super.key, required this.song, required this.queue});

  final CurrentSong song;
  final List<CurrentSong> queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 166,
      height: 212,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            final index = queue.indexWhere((item) => item.path == song.path);
            ref.read(queueProvider.notifier).setQueue(queue);
            ref.read(queueIndexProvider.notifier).setIndex(index < 0 ? 0 : index);
            ref.read(currentSongProvider.notifier).setSong(song);
            await ref.read(audioPlayerProvider).openFile(song.path);
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlayerPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: song.artwork == null
                        ? ColoredBox(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: const Center(child: Icon(Icons.music_note_rounded, size: 42)),
                          )
                        : Image.memory(song.artwork!, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 10),
                Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  song.artist.isEmpty ? 'Unknown Artist' : song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
