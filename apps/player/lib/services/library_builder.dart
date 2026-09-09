import 'package:flutter/foundation.dart';

import '../models/current_song.dart';
import 'metadata_service.dart';
import 'music_scanner.dart';

class LibraryBuilder {
  final MusicScanner _scanner = MusicScanner();
  final MetadataService _metadata = const MetadataService();

  Future<List<CurrentSong>> buildLibrary(String folderPath) async {
    final songs = <CurrentSong>[];

    debugPrint("Scanning: $folderPath");

    final files = await _scanner.scanFolder(folderPath);

    for (final file in files) {
      try {
        final song = await _metadata.readMetadata(file.path);
        songs.add(song);
      } catch (e) {
        debugPrint("Failed: ${file.path}");
        debugPrint(e.toString());
      }
    }

    debugPrint("Finished. ${songs.length} songs found.");

    return songs;
  }
}
