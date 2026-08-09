import 'package:flutter/material.dart';

import 'widgets/greeting_header.dart';
import 'widgets/playlist_card.dart';
import 'widgets/recent_album_card.dart';
import 'widgets/section_title.dart';
import 'widgets/song_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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

            const SongTile(
              title: 'Blinding Lights',
              artist: 'The Weeknd',
            ),

            const SongTile(
              title: 'Believer',
              artist: 'Imagine Dragons',
            ),

            const SongTile(
              title: 'Starboy',
              artist: 'The Weeknd',
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