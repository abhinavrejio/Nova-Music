import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/recent_provider.dart';
import 'section_header.dart';
import 'song_rail.dart';

class RecentlyPlayedSection extends ConsumerWidget {
  const RecentlyPlayedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(recentlyPlayedSongsProvider);

    if (songs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Recently Played",
          subtitle: "${songs.length} songs",
          actionText: "View All",
          onPressed: () {
            // TODO: Navigate to Recently Played page
          },
        ),

        const SizedBox(height: 20),

        SongRail(
          songs: songs,
        ),
      ],
    );
  }
}