import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/current_song.dart';
import 'artwork_service.dart';
import 'ffprobe_service.dart';

class MetadataService {
  const MetadataService();

  Future<CurrentSong> readMetadata(String path) async {
    Uint8List? artwork;
    String title = path.split(Platform.pathSeparator).last;
    String artist = 'Unknown Artist';
    String album = 'Unknown Album';
    String genre = '';
    Duration duration = Duration.zero;

    try {
      final json = await FFprobeService().read(path);
      final format = json['format'];
      final tags = (format is Map<String, dynamic> ? format['tags'] : null)
              as Map<String, dynamic>? ??
          const <String, dynamic>{};

      final rawDuration = format is Map ? format['duration'] : null;
      final resolvedDuration = double.tryParse(rawDuration?.toString() ?? '0') ?? 0;

      title = tags['title']?.toString() ??
          path.split(Platform.pathSeparator).last;
      artist = tags['artist']?.toString() ?? artist;
      album = tags['album']?.toString() ?? album;
      genre = tags['genre']?.toString() ?? genre;
      duration = Duration(milliseconds: (resolvedDuration * 1000).round());
    } catch (error) {
      debugPrint('Metadata fallback for $path: $error');
    }

    try {
      artwork = await ArtworkService().extractArtwork(path);
    } catch (_) {
      artwork = null;
    }

    return CurrentSong(
      path: path,
      title: title,
      artist: artist,
      album: album,
      genre: genre,
      importedAt: DateTime.now(),
      duration: duration,
      artwork: artwork,
    );
  }
}