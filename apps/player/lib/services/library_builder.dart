import 'package:flutter/foundation.dart';

import '../repositories/library_repository.dart';
import 'metadata_service.dart';
import 'music_scanner.dart';

class LibraryBuilder {
  final MusicScanner _scanner = MusicScanner();
  final MetadataService _metadata = const MetadataService();

  Future<void> buildLibrary(String folderPath) async {
    debugPrint("STEP 1");

    final files = await _scanner.scanFolder(folderPath);
    debugPrint("STEP 2: ${files.length} files");

    LibraryRepository.instance.clear();

    for (final file in files) {
      debugPrint("STEP 3: ${file.path}");

      try {
        final song = await _metadata.readMetadata(file.path);

        debugPrint("STEP 4: ${song.title}");

        LibraryRepository.instance.add(song);

        debugPrint(
          "STEP 5: ${LibraryRepository.instance.songs.length}",
        );
      } catch (e, stack) {
        debugPrint("ERROR:");
        debugPrint(e.toString());
        debugPrint(stack.toString());
      }
    }

    debugPrint("STEP 6");
  }
}