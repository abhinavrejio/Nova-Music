import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/current_song.dart';
import 'library/library_provider.dart';

const _mostPlayedStorageKey = 'most_played_counts';

final mostPlayedProvider = NotifierProvider<MostPlayedNotifier, Map<String, int>>(
  MostPlayedNotifier.new,
);

class MostPlayedNotifier extends Notifier<Map<String, int>> {
  int _revision = 0;

  @override
  Map<String, int> build() {
    _load();
    return const {};
  }

  void record(String path) {
    if (path.isEmpty) return;
    _revision++;
    state = {
      ...state,
      path: (state[path] ?? 0) + 1,
    };
    _persist();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mostPlayedStorageKey);
    if (revision != _revision || raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    state = decoded.map(
      (path, count) => MapEntry(path, (count as num).toInt()),
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mostPlayedStorageKey, jsonEncode(state));
  }
}

final mostPlayedSongsProvider = Provider<List<CurrentSong>>((ref) {
  final counts = ref.watch(mostPlayedProvider);
  final songs = ref.watch(libraryProvider).where((song) => counts.containsKey(song.path)).toList();
  songs.sort((a, b) => (counts[b.path] ?? 0).compareTo(counts[a.path] ?? 0));
  return songs;
});
