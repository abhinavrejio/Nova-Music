import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/song.dart';
import '../../repositories/music_repository.dart';

import 'widgets/continue_listening_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/playlist_card.dart';
import 'widgets/recent_album_card.dart';
import 'widgets/section_title.dart';
import 'widgets/song_tile.dart';
import '../../models/album.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Song> songs = const MusicRepository().getSongs();
    final List<Album> albums = const MusicRepository().getAlbums();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingHeader(),

            const SizedBox(height: 24),

            const ContinueListeningCard(),

            const SizedBox(height: 32),

            const SectionTitle(title: 'Made For You'),

            const SizedBox(height: 16),

SizedBox(
  height: 190,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: albums.length,
    itemBuilder: (context, index) {
      return RecentAlbumCard(
        album: albums[index],
      );
    },
  ),
),

const SizedBox(height: 32),

            const SectionTitle(title: 'Recently Played'),

const SizedBox(height: 15),

SizedBox(
  height: 190,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: albums.length,
    itemBuilder: (context, index) {
      return RecentAlbumCard(
        album: albums[index],
      );
    },
  ),
),

            const SizedBox(height: 30),

            const SectionTitle(title: 'Quick Picks'),

            ...songs.map(
              (song) => SongTile(
                song: song,
              ),
            ),

            const SizedBox(height: 30),

            const SectionTitle(title: 'Recommended'),

            const SizedBox(height: 15),

            const PlaylistCard(title: 'Top Hits'),
            const PlaylistCard(title: 'Workout Mix'),
            const PlaylistCard(title: 'Chill Vibes'),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}