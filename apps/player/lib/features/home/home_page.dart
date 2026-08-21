import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/continue_listening_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/made_for_you_card.dart';
import 'widgets/playlist_card.dart';
import 'widgets/recent_album_card.dart';
import 'widgets/section_title.dart';
import 'widgets/song_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  MadeForYouCard(
                    title: 'Daily Mix',
                    subtitle: '32 Songs',
                    icon: Icons.favorite,
                  ),
                  MadeForYouCard(
                    title: 'Workout',
                    subtitle: '48 Songs',
                    icon: Icons.fitness_center,
                  ),
                  MadeForYouCard(
                    title: 'Relax',
                    subtitle: '25 Songs',
                    icon: Icons.nightlight_round,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

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