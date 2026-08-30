import '../models/current_song.dart';

class LibraryRepository {
  LibraryRepository._();

  static final LibraryRepository instance = LibraryRepository._();

  final List<CurrentSong> _songs = [];

  List<CurrentSong> get songs => List.unmodifiable(_songs);

  void add(CurrentSong song) {
    final exists = _songs.any((s) => s.path == song.path);

    if (!exists) {
      _songs.add(song);
    }
  }

  void remove(CurrentSong song) {
    _songs.removeWhere((s) => s.path == song.path);
  }

  void clear() {
    _songs.clear();
  }
}