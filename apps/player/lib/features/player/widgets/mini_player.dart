import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/audio_player_provider.dart';
import '../../../providers/current_song_provider.dart';
import '../player_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return const SizedBox.shrink();
    }

    final player = ref.watch(audioPlayerProvider);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlayerPage(),
            ),
          );
        },
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: song.artwork != null
                      ? Image.memory(
                          song.artwork!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.deepPurple,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      song.artist.isEmpty
                          ? "Unknown Artist"
                          : song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  player.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                onPressed: () {
                  player.togglePlayPause();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}