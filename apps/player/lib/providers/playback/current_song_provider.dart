import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/current_song.dart';

class CurrentSongNotifier extends Notifier<CurrentSong?> {
  @override
  CurrentSong? build() => null;

  void setSong(CurrentSong song) {
    state = song;
  }

  void clear() {
    state = null;
  }
}

final currentSongProvider =
    NotifierProvider<CurrentSongNotifier, CurrentSong?>(
  CurrentSongNotifier.new,
);