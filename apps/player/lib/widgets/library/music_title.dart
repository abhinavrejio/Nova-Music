import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../design/colors.dart';
import '../../design/radii.dart';

class MusicTile extends StatelessWidget {
  const MusicTile({
    super.key,
    required this.title,
    required this.artist,
    this.album,
    this.duration,
    this.artwork,
    this.trailing,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  final String title;
  final String artist;
  final String? album;
  final String? duration;
  final Uint8List? artwork;

  final Widget? trailing;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: artwork != null
                  ? Image.memory(
                      artwork!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    album == null ? artist : '$artist • $album',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (duration != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  duration!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}