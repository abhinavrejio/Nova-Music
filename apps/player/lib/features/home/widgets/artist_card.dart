import 'package:flutter/material.dart';
import 'dart:typed_data';

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage:
                  image != null ? MemoryImage(image!) : null,
              child: image == null
                  ? const Icon(Icons.person, size: 46)
                  : null,
            ),

            const SizedBox(height: 14),

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}