import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/playlist.dart';

const _playlistStorageKey = 'playlists';

class PlaylistNotifier extends Notifier<List<Playlist>> {
  int _revision = 0;

  @override
  List<Playlist> build() {
    load();
    return const [];
  }

  Future<void> load() async {
    final revision = ++_revision;
    final loaded = await _loadFromPrefs();

    if (revision != _revision) {
      return;
    }

    state = loaded;
  }

  Future<List<Playlist>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistStorageKey);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) {
      final map = item as Map<String, dynamic>;
      return Playlist(
        id: map['id'] as String,
        name: map['name'] as String,
        songPaths: List<String>.from(map['songPaths'] as List<dynamic>),
        description: map['description'] as String? ?? '',
        isSmartPlaylist: map['isSmartPlaylist'] as bool? ?? false,
        isPinned: map['isPinned'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      state.map((playlist) {
        return {
          'id': playlist.id,
          'name': playlist.name,
          'songPaths': playlist.songPaths,
          'description': playlist.description,
          'isSmartPlaylist': playlist.isSmartPlaylist,
          'isPinned': playlist.isPinned,
        };
      }).toList(),
    );

    await prefs.setString(_playlistStorageKey, payload);
  }

  Future<void> createPlaylist(String name) async {
    _revision++;
    final next = [
      ...state,
      Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        songPaths: const [],
      ),
    ];

    state = next;
    await _persist();
  }

  Future<void> deletePlaylist(String id) async {
    _revision++;
    state = state.where((p) => p.id != id).toList();
    await _persist();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    _revision++;
    state = [
      for (final playlist in state)
        if (playlist.id == id) playlist.copyWith(name: newName) else playlist,
    ];
    await _persist();
  }

  Future<void> togglePinned(String id) async {
    _revision++;
    state = [
      for (final playlist in state)
        if (playlist.id == id)
          playlist.copyWith(isPinned: !playlist.isPinned)
        else
          playlist,
    ];
    await _persist();
  }

  Future<void> addSong(String id, String path) async {
    _revision++;
    state = [
      for (final playlist in state)
        if (playlist.id == id)
          playlist.copyWith(songPaths: [...playlist.songPaths, path])
        else
          playlist,
    ];
    await _persist();
  }

  Future<void> removeSong(String id, String path) async {
    _revision++;
    state = [
      for (final playlist in state)
        if (playlist.id == id)
          playlist.copyWith(
            songPaths: playlist.songPaths.where((e) => e != path).toList(),
          )
        else
          playlist,
    ];
    await _persist();
  }
}

final playlistProvider = NotifierProvider<PlaylistNotifier, List<Playlist>>(
  PlaylistNotifier.new,
);
