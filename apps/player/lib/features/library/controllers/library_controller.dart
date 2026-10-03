import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../providers/library/library_provider.dart';

final songsProvider = Provider<List<CurrentSong>>((ref) {
  return ref.watch(libraryProvider);
});
