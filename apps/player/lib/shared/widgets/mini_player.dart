import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/player/player_page.dart';
import '../../providers/audio/audio_player_provider.dart';
import '../../providers/playback/current_song_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return const SizedBox.shrink();
    }

    final audio = ref.read(audioPlayerProvider);

    return Material(
      elevation: 8,
      color: Colors.deepPurple,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlayerPage(),
            ),
          );
        },
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              const SizedBox(width: 12),

              _AlbumArtwork(song.artwork),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title.replaceAll(".mp3", ""),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              StreamBuilder<bool>(
                stream: audio.playingStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data ?? false;

                  return IconButton(
                    icon: Icon(
                      playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      audio.togglePlayPause();
                    },
                  );
                },
              ),

              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumArtwork extends StatelessWidget {
  final Uint8List? artwork;

  const _AlbumArtwork(this.artwork);

  @override
  Widget build(BuildContext context) {
    if (artwork != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          artwork!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.deepPurple,
      ),
    );
  }
}