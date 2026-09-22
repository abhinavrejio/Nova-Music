import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/download_provider.dart';
import '../../../providers/library/liked_songs_provider.dart';
import '../../../providers/library/library_provider.dart';
import '../../../providers/most_played_provider.dart';
import '../../../providers/recent_provider.dart';
import '../pages/collection_pages.dart';
import '../pages/liked_songs_page.dart';
import 'collection_card.dart';

class LibraryCollections extends ConsumerWidget {
  const LibraryCollections({
    super.key,
    required this.songCount,
  });

  final int songCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongs = ref.watch(likedSongsProvider);
    final recentlyPlayed = ref.watch(recentlyPlayedSongsProvider);
    final recentlyAdded = ref
      .watch(libraryProvider)
      .where((song) => song.importedAt != null)
      .length;
    final mostPlayed = ref.watch(mostPlayedSongsProvider);
    final downloads = ref.watch(downloadProvider);
    final collections = [
      CollectionCard(
        title: "Liked Songs",
        icon: Icons.favorite,
        color: Colors.red,
        count: likedSongs.length,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LikedSongsPage(),
            ),
          );
        },
      ),
      CollectionCard(
        title: "Recently Played",
        icon: Icons.history,
        color: Colors.blue,
        count: recentlyPlayed.length,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecentlyPlayedPage()),
        ),
      ),
      CollectionCard(
        title: "Recently Added",
        icon: Icons.new_releases,
        color: Colors.green,
        count: recentlyAdded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecentlyAddedPage()),
        ),
      ),
      CollectionCard(
        title: "Most Played",
        icon: Icons.trending_up,
        color: Colors.orange,
        count: mostPlayed.length,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MostPlayedPage()),
        ),
      ),
      CollectionCard(
        title: "Downloads",
        icon: Icons.download,
        color: Colors.purple,
        count: downloads.length,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DownloadsPage()),
        ),
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: collections.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (_, index) => collections[index],
      ),
    );
  }
}