import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../design/colors.dart';
import 'app_card.dart';

class ArtistCard extends StatelessWidget {
  const ArtistCard({
    super.key,
    required this.name,
    this.image,
    this.onTap,
  });

  final String name;
  final Uint8List? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: 170,
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.surface,
            backgroundImage:
                image != null ? MemoryImage(image!) : null,
            child: image == null
                ? const Icon(Icons.person, size: 52)
                : null,
          ),

          const SizedBox(height: 18),

          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}