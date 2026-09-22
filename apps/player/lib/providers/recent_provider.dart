import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/current_song.dart';
import 'library/library_provider.dart';

const _recentStorageKey = 'recently_played_paths';

final recentProvider = NotifierProvider<RecentNotifier, List<String>>(
  RecentNotifier.new,
);

class RecentNotifier extends Notifier<List<String>> {
  int _revision = 0;

  @override
  List<String> build() {
    _load();
    return const [];
  }

  void record(String path) {
    if (path.isEmpty) return;
    _revision++;
    state = [path, ...state].take(100).toList();
    _persist();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentStorageKey);
    if (revision != _revision || raw == null) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded.whereType<String>().toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentStorageKey, jsonEncode(state));
  }
}

final recentlyPlayedSongsProvider = Provider<List<CurrentSong>>((ref) {
  final paths = ref.watch(recentProvider);
  final songsByPath = {
    for (final song in ref.watch(libraryProvider)) song.path: song,
  };
  return paths
      .map((path) => songsByPath[path])
      .whereType<CurrentSong>()
      .toList();
});
