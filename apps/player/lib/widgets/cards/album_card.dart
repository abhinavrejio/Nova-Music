import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../design/colors.dart';
import '../../design/radii.dart';
import 'app_card.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.artist,
    this.artwork,
    this.onTap,
  });

  final String title;
  final String artist;
  final Uint8List? artwork;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: 180,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppRadii.md),
            child: artwork != null
                ? Image.memory(
                    artwork!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 160,
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.album,
                        size: 48,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}