import 'package:flutter/material.dart';

import '../../../models/current_song.dart';
import 'home_song_card.dart';

class SongRail extends StatelessWidget {
  const SongRail({
    super.key,
    required this.songs,
  });

  final List<CurrentSong> songs;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return HomeSongCard(
            song: songs[index],
            queue: songs,
          );
        },
      ),
    );
  }
}
