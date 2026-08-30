import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/current_song.dart';
import 'artwork_service.dart';
import 'ffprobe_service.dart';

class MetadataService {
  const MetadataService();

  Future<CurrentSong> readMetadata(String path) async {
    // Read metadata using FFprobe
    final json = await FFprobeService().read(path);

    final format = json["format"] as Map<String, dynamic>;
    final tags = format["tags"] as Map<String, dynamic>? ?? {};

    // Extract album artwork
    Uint8List? artwork;

    try {
      artwork = await ArtworkService().extractArtwork(path);
    } catch (_) {
      artwork = null;
    }

    return CurrentSong(
      path: path,
      title: tags["title"] ??
          path.split(Platform.pathSeparator).last,
      artist: tags["artist"] ?? "Unknown Artist",
      album: tags["album"] ?? "Unknown Album",
      duration: Duration(
        milliseconds: (
          (double.tryParse(format["duration"]?.toString() ?? "0") ?? 0) * 1000
        ).round(),
      ),
      artwork: artwork,
    );
  }
}