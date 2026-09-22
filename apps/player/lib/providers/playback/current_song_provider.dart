import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/current_song.dart';
import '../most_played_provider.dart';
import '../recent_provider.dart';

class CurrentSongNotifier extends Notifier<CurrentSong?> {
  @override
  CurrentSong? build() => null;

  void setSong(CurrentSong song) {
    state = song;
    ref.read(recentProvider.notifier).record(song.path);
    ref.read(mostPlayedProvider.notifier).record(song.path);
  }

  void clear() {
    state = null;
  }
}

final currentSongProvider =
    NotifierProvider<CurrentSongNotifier, CurrentSong?>(
  CurrentSongNotifier.new,
);