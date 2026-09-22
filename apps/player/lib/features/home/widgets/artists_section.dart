import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/library/library_provider.dart';
import 'artist_card.dart';
import 'section_header.dart';

class ArtistsSection extends ConsumerWidget {
  const ArtistsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider);

    final artists = <String, dynamic>{};

    for (final song in songs) {
      if (song.artist.isEmpty) continue;
      artists.putIfAbsent(song.artist, () => song);
    }

    if (artists.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Artists',
          subtitle: '${artists.length} artists',
          actionText: 'View All',
          onPressed: () {},
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final song = artists.values.elementAt(index);

              return ArtistCard(
                name: song.artist,
                image: song.artwork,
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}