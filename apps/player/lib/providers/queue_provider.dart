import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/current_song.dart';

class QueueNotifier extends Notifier<List<CurrentSong>> {
  @override
  List<CurrentSong> build() => [];

  void setQueue(List<CurrentSong> songs) {
    state = List.from(songs);
  }

  void clear() {
    state = [];
  }
}

final queueProvider =
    NotifierProvider<QueueNotifier, List<CurrentSong>>(
  QueueNotifier.new,
);