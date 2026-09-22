import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/playlist.dart';

class PlaylistNotifier extends Notifier<List<Playlist>> {
  @override
  List<Playlist> build() => [];

  void createPlaylist(String name) {
    state = [
      ...state,
      Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        songPaths: const [],
      ),
    ];
  }

  void deletePlaylist(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void renamePlaylist(String id, String newName) {
    state = [
      for (final playlist in state)
        if (playlist.id == id)
          playlist.copyWith(name: newName)
        else
          playlist,
    ];
  }

  void addSong(String id, String path) {
    state = [
      for (final playlist in state)
        if (playlist.id == id)
          playlist.copyWith(
            songPaths: [...playlist.songPaths, path],
          )
        else
          playlist,
    ];
  }

  void removeSong(String id, String path) {
    state = [
      for (final playlist in state)
        if (playlist.id == id)
          playlist.copyWith(
            songPaths: playlist.songPaths
                .where((e) => e != path)
                .toList(),
          )
        else
          playlist,
    ];
  }
}

final playlistProvider =
    NotifierProvider<PlaylistNotifier, List<Playlist>>(
  PlaylistNotifier.new,
);