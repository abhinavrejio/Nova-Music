import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class PlaylistCard extends StatelessWidget {
  final String title;

  const PlaylistCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.queue_music,
            color: Colors.white,
          ),
        ),

        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          'Playlist',
          style: AppTextStyles.caption,
        ),

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}