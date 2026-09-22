import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/library/library_provider.dart';
import 'album_card.dart';
import 'section_header.dart';

class AlbumsSection extends ConsumerWidget {
  const AlbumsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider);

    final albums = <String, dynamic>{};

    for (final song in songs) {
      if (song.album.isEmpty) continue;

      albums.putIfAbsent(song.album, () => song);
    }

    if (albums.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Albums",
          subtitle: "${albums.length} albums",
          actionText: "View All",
          onPressed: () {
            // TODO
          },
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            separatorBuilder: (_, index) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              final song = albums.values.elementAt(index);

              return AlbumCard(
                title: song.album,
                artist: song.artist,
                artwork: song.artwork,
                onTap: () {
                  // TODO
                },
              );
            },
          ),
        ),
      ],
    );
  }
}