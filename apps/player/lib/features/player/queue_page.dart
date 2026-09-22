import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio/audio_player_provider.dart';
import '../../providers/playback/current_song_provider.dart';
import '../../providers/playback/queue_index_provider.dart';
import '../../providers/playback/queue_provider.dart';
import 'player_page.dart';

class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider);
    final currentSong = ref.watch(currentSongProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        centerTitle: true,
      ),
      body: queue.isEmpty
          ? const Center(
              child: Text(
                'No songs in queue',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: queue.length,
              onReorderItem: (oldIndex, newIndex) {
                final currentPath = ref.read(currentSongProvider)?.path;
                ref.read(queueProvider.notifier).reorderItem(oldIndex, newIndex);

                if (currentPath != null) {
                  final updatedQueue = ref.read(queueProvider);
                  final updatedIndex = updatedQueue.indexWhere(
                    (song) => song.path == currentPath,
                  );
                  if (updatedIndex >= 0) {
                    ref.read(queueIndexProvider.notifier).setIndex(updatedIndex);
                  }
                }
              },
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = currentSong?.path == song.path;

                return Material(
                  key: ValueKey(song.path),
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      ref.read(queueIndexProvider.notifier).setIndex(index);
                      ref.read(currentSongProvider.notifier).setSong(song);

                      await ref.read(audioPlayerProvider).openFile(song.path);

                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PlayerPage(),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: song.artwork != null
                                  ? Image.memory(
                                      song.artwork!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.deepPurple.shade100,
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  song.artist.isEmpty
                                      ? 'Unknown Artist'
                                      : song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isCurrent)
                                Text(
                                  'Playing',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(song.duration),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                          IconButton(
                            tooltip: 'Remove from queue',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () async {
                              final queueIndex = ref.read(queueIndexProvider);
                              final wasCurrent = queueIndex == index;

                              if (wasCurrent) {
                                await ref.read(audioPlayerProvider).stop();
                                ref.read(currentSongProvider.notifier).clear();
                              }

                              ref.read(queueProvider.notifier).removeAt(index);

                              if (queue.isEmpty) {
                                ref.read(queueIndexProvider.notifier).reset();
                              } else if (wasCurrent) {
                                ref.read(queueIndexProvider.notifier).setIndex(
                                  index.clamp(0, queue.length - 1),
                                );
                              } else if (index < queueIndex) {
                                ref.read(queueIndexProvider.notifier).setIndex(
                                  queueIndex - 1,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
