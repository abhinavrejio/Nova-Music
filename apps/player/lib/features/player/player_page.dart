import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_player_provider.dart';
import '../../providers/current_song_provider.dart';
import '../../providers/playback_provider.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Now Playing"),
        ),
        body: const Center(
          child: Text(
            "No song selected",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Now Playing"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer(
            builder: (context, ref, _) {
              final position = ref.watch(positionProvider);
              final duration = ref.watch(durationProvider);
              final playing = ref.watch(playingProvider);

              final service = ref.read(audioPlayerProvider);

              final isPlaying = playing.value ?? service.isPlaying;

              return Column(
                children: [
                  const SizedBox(height: 12),

                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.deepPurple.shade100,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: song.artwork != null
                          ? Image.memory(
                              song.artwork!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.music_note,
                              size: 120,
                              color: Colors.deepPurple,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    song.artist.isEmpty
                        ? "Unknown Artist"
                        : song.artist,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  ProgressBar(
                    progress: position.value ?? Duration.zero,
                    total: duration.value ?? song.duration,
                    onSeek: (value) {
                      ref.read(audioPlayerProvider).seek(value);
                    },
                  ),

                  const SizedBox(height: 8),

                  IconButton(
                    iconSize: 72,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                    ),
                    onPressed: () {
                      ref.read(audioPlayerProvider).togglePlayPause();
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}