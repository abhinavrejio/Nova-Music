import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/song_mapper.dart';
import '../models/song/song.dart';
import 'music_provider.dart';

final songsProvider = FutureProvider<List<Song>>((ref) async {
  final repository = ref.watch(musicRepositoryProvider);
  final songs = await repository.getSongs();
  return songs.map(SongMapper.fromSongModel).toList();
});
