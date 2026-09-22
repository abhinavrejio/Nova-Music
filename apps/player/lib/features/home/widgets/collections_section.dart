import 'package:flutter/material.dart';

import 'collection_card.dart';
import 'section_title.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "Collections",
          actionText: "View All",
        ),

        const SizedBox(height: 18),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              CollectionCard(
                icon: Icons.favorite_rounded,
                title: "Liked Songs",
                subtitle: "248 songs",
                color: Colors.red,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.history_rounded,
                title: "Recently Played",
                subtitle: "53 songs",
                color: Colors.blue,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.trending_up_rounded,
                title: "Most Played",
                subtitle: "48 songs",
                color: Colors.orange,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.download_rounded,
                title: "Downloads",
                subtitle: "25 songs",
                color: Colors.purple,
              ),

              SizedBox(width: 16),

              CollectionCard(
                icon: Icons.folder_rounded,
                title: "Folders",
                subtitle: "6 folders",
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