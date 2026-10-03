import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/download_provider.dart';
import '../../../providers/library/liked_songs_provider.dart';
import '../../../providers/library_folder_provider.dart';
import '../../../providers/most_played_provider.dart';
import '../../../providers/recent_provider.dart';
import 'collection_card.dart';
import 'section_title.dart';

class CollectionsSection extends ConsumerWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedCount = ref.watch(likedSongsProvider).length;
    final recentCount = ref.watch(recentlyPlayedSongsProvider).length;
    final mostPlayedCount = ref.watch(mostPlayedSongsProvider).length;
    final downloadCount = ref.watch(downloadProvider).length;
    final folderCount = ref.watch(libraryFolderProvider).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: "Collections",
          actionText: "View All",
          onPressed: () => context.go('/library'),
        ),

        const SizedBox(height: 18),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CollectionCard(
                icon: Icons.favorite_rounded,
                title: "Liked Songs",
                subtitle: "$likedCount songs",
                color: Colors.red,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.history_rounded,
                title: "Recently Played",
                subtitle: "$recentCount songs",
                color: Colors.blue,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.trending_up_rounded,
                title: "Most Played",
                subtitle: "$mostPlayedCount songs",
                color: Colors.orange,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.download_rounded,
                title: "Downloads",
                subtitle: "$downloadCount songs",
                color: Colors.purple,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.folder_rounded,
                title: "Folders",
                subtitle: "$folderCount folders",
                color: Colors.amber,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.add_rounded,
                title: "Create",
                subtitle: "Playlist",
                color: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
