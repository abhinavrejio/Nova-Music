import 'dart:typed_data';

import 'package:flutter/material.dart';

class AlbumArtwork extends StatelessWidget {
  final Uint8List? artwork;
  final double size;

  const AlbumArtwork({
    super.key,
    this.artwork,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: artwork != null
            ? Image.memory(
                artwork!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 120,
                  color: Colors.deepPurple,
                ),
              ),
      ),
    );

    return box;
  }
}