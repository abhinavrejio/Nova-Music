import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/current_song.dart';

class QueueNotifier extends Notifier<List<CurrentSong>> {
  @override
  List<CurrentSong> build() => [];

  void setQueue(List<CurrentSong> songs) {
    state = List.from(songs);
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;

    final updated = List<CurrentSong>.from(state)..removeAt(index);
    state = updated;
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex > state.length) return;

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) targetIndex--;

    final updated = List<CurrentSong>.from(state);
    final song = updated.removeAt(oldIndex);
    updated.insert(targetIndex, song);
    state = updated;
  }

  void reorderItem(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex >= state.length) return;

    final updated = List<CurrentSong>.from(state);
    final song = updated.removeAt(oldIndex);
    updated.insert(newIndex, song);
    state = updated;
  }

  void clear() {
    state = [];
  }
}

final queueProvider =
    NotifierProvider<QueueNotifier, List<CurrentSong>>(
  QueueNotifier.new,
);