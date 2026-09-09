import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/current_song.dart';

class PlayQueueNotifier extends Notifier<List<CurrentSong>> {
  int _currentIndex = -1;

  @override
  List<CurrentSong> build() => [];

  void setQueue(List<CurrentSong> songs, CurrentSong currentSong) {
    state = songs;

    _currentIndex = songs.indexWhere(
      (song) => song.path == currentSong.path,
    );
  }

  CurrentSong? get current {
    if (_currentIndex < 0 || _currentIndex >= state.length) {
      return null;
    }

    return state[_currentIndex];
  }

  CurrentSong? next() {
    if (_currentIndex + 1 >= state.length) {
      return null;
    }

    _currentIndex++;
    return state[_currentIndex];
  }

  CurrentSong? previous() {
    if (_currentIndex - 1 < 0) {
      return null;
    }

    _currentIndex--;
    return state[_currentIndex];
  }
}

final playQueueProvider =
    NotifierProvider<PlayQueueNotifier, List<CurrentSong>>(
  PlayQueueNotifier.new,
);