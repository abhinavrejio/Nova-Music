import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/current_song.dart';
import '../services/library_builder.dart';
import '../services/library_folder_service.dart';

class LibraryNotifier extends Notifier<List<CurrentSong>> {
  @override
  List<CurrentSong> build() {
    _loadLibrary();
    return [];
  }

  Future<void> _loadLibrary() async {
    await rescanAll();
  }

  Future<void> scanFolder(String folderPath) async {
    final songs = await LibraryBuilder().buildLibrary(folderPath);

    final updated = [...state];

    for (final song in songs) {
      if (!updated.any((s) => s.path == song.path)) {
        updated.add(song);
      }
    }

    state = updated;
  }

  Future<void> rescanAll() async {
    final folders = await LibraryFolderService().loadFolders();

    final allSongs = <CurrentSong>[];

    for (final folder in folders) {
      final songs = await LibraryBuilder().buildLibrary(folder.path);

      for (final song in songs) {
        if (!allSongs.any((s) => s.path == song.path)) {
          allSongs.add(song);
        }
      }
    }

    state = allSongs;
  }

  void clear() {
    state = [];
  }
}

final libraryProvider =
    NotifierProvider<LibraryNotifier, List<CurrentSong>>(
  LibraryNotifier.new,
);
