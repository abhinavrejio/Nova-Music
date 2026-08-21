import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/song.dart';
import 'music_provider.dart';

final songsProvider = Provider<List<Song>>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return repository.getSongs();
});