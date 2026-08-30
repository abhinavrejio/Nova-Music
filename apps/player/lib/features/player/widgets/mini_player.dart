import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/current_song_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      color: Colors.deepPurple,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/player');
        },
        child: SizedBox(
          height: 72,
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
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

              IconButton(
                onPressed: () {
                  // We'll connect this later.
                },
                icon: const Icon(
                  Icons.pause,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),
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
          width: 54,
          height: 54,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
      ),
    );
  }
}