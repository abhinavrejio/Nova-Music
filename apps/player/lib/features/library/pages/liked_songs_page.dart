import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/audio_player_provider.dart';
import '../../../providers/current_song_provider.dart';
import '../../../providers/liked_songs_provider.dart';
import '../../../providers/queue_provider.dart';
import '../../../providers/queue_index_provider.dart';

import '../../player/player_page.dart';

class LikedSongsPage extends ConsumerWidget {
  const LikedSongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(likedSongsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Songs"),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                "No liked songs yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];

                return ListTile(
                  leading: song.artwork != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            song.artwork!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.music_note),
                        ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    ref.read(queueProvider.notifier).setQueue(songs);
                    ref.read(queueIndexProvider.notifier).setIndex(index);
                    ref.read(currentSongProvider.notifier).setSong(song);

                    await ref.read(audioPlayerProvider).openFile(song.path);

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlayerPage(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}