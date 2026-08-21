import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/song_provider.dart';

import 'widgets/greeting_header.dart';
import 'widgets/playlist_card.dart';
import 'widgets/recent_album_card.dart';
import 'widgets/section_title.dart';
import 'widgets/song_tile.dart';
import 'widgets/continue_listening_card.dart';
const GreetingHeader(),
const SizedBox(height: 24),

const ContinueListeningCard(),

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(songsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingHeader(),

            const SizedBox(height: 30),

            const SectionTitle(title: 'Recently Played'),

            const SizedBox(height: 15),

            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  RecentAlbumCard(title: 'Album 1'),
                  SizedBox(width: 12),
                  RecentAlbumCard(title: 'Album 2'),
                  SizedBox(width: 12),
                  RecentAlbumCard(title: 'Album 3'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const SectionTitle(title: 'Quick Picks'),

            ...songs.map(
              (song) => SongTile(
                title: song.title,
                artist: song.artist,
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