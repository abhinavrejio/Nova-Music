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

  String _key(String path) => path.replaceAll('/', '\\').toLowerCase();

  List<String> _dedupe(Iterable<String> paths) {
    final seen = <String>{};
    final result = <String>[];

    for (final path in paths) {
      if (path.isEmpty) continue;

      final key = _key(path);
      if (seen.add(key)) {
        result.add(path);
      }

      if (result.length == 100) break;
    }

    return result;
  }

  void record(String path) {
    if (path.isEmpty) return;

    _revision++;

    final previous = state.where(
      (existing) => _key(existing) != _key(path),
    );

    state = [path, ...previous].take(100).toList(growable: false);
    _persist();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentStorageKey);

    if (revision != _revision || raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return;

      state = _dedupe(decoded.whereType<String>());
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recentStorageKey,
      jsonEncode(state),
    );
  }
}

final recentlyPlayedSongsProvider = Provider<List<CurrentSong>>((ref) {
  final paths = ref.watch(recentProvider);
  final songsByPath = <String, CurrentSong>{
    for (final song in ref.watch(libraryProvider))
      song.path.replaceAll('/', '\\').toLowerCase(): song,
  };

  final result = <CurrentSong>[];
  final seen = <String>{};

  for (final path in paths) {
    final key = path.replaceAll('/', '\\').toLowerCase();

    if (!seen.add(key)) continue;

    final song = songsByPath[key];
    if (song != null) {
      result.add(song);
    }
  }

  return result;
});
