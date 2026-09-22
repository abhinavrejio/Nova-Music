import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/download_provider.dart';
import '../../../providers/library/library_provider.dart';
import '../../../providers/most_played_provider.dart';
import '../../../providers/recent_provider.dart';
import 'collection_songs_page.dart';

class RecentlyPlayedPage extends ConsumerWidget {
  const RecentlyPlayedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CollectionSongsPage(
        title: 'Recently Played',
        songs: ref.watch(recentlyPlayedSongsProvider),
        emptyMessage: 'No recently played songs.',
      );
}

class RecentlyAddedPage extends ConsumerWidget {
  const RecentlyAddedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider).where((song) => song.importedAt != null).toList()
      ..sort((a, b) => b.importedAt!.compareTo(a.importedAt!));
    return CollectionSongsPage(
      title: 'Recently Added',
      songs: songs,
      emptyMessage: 'No recently added songs.',
    );
  }
}

class MostPlayedPage extends ConsumerWidget {
  const MostPlayedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CollectionSongsPage(
        title: 'Most Played',
        songs: ref.watch(mostPlayedSongsProvider),
        emptyMessage: 'No most played songs.',
      );
}

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => CollectionSongsPage(
        title: 'Downloads',
        songs: ref.watch(downloadProvider),
        emptyMessage: 'No downloaded music.',
      );
}