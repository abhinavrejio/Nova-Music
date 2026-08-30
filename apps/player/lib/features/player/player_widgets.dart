import 'dart:typed_data';

import 'package:flutter/material.dart';

class AlbumArtwork extends StatelessWidget {
  final Uint8List? artwork;

  const AlbumArtwork({
    super.key,
    this.artwork,
  });

  @override
  Widget build(BuildContext context) {
    if (artwork != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.memory(
          artwork!,
          width: 300,
          height: 300,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.music_note,
        size: 120,
        color: Colors.deepPurple,
      ),
    );
  }
}