import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/current_song.dart';
import 'favorites_provider.dart';
import 'library_provider.dart';

final likedSongsProvider = Provider<List<CurrentSong>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  final library = ref.watch(libraryProvider);

  return library
      .where((song) => favorites.contains(song.path))
      .toList();
});