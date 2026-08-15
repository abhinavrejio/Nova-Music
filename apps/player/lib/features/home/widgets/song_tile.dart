import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String artist;

  const SongTile({
    super.key,
    required this.title,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(
          Icons.music_note,
          color: Colors.white,
        ),
      ),

      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        artist,
        style: AppTextStyles.caption,
      ),

      trailing: const Icon(Icons.more_vert),
    );
  }
}