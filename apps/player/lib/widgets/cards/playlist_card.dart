import 'package:flutter/material.dart';

import '../../design/radii.dart';
import 'app_card.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.title,
    required this.songCount,
    this.onTap,
  });

  final String title;
  final int songCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: 200,
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppRadii.md),
              color: Colors.deepPurple,
            ),
            child: const Center(
              child: Icon(
                Icons.queue_music,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 4),

          Text("$songCount songs"),
        ],
      ),
    );
  }
}