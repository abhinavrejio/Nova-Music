import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _favoritesStorageKey = 'favorites';

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return <String>{};
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesStorageKey) ?? const [];
    state = saved.toSet();
  }

  Future<void> _load() async {
    await load();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesStorageKey, state.toList());
  }

  bool isFavorite(String path) {
    return state.contains(path);
  }

  Future<void> toggle(String path) async {
    final updated = Set<String>.from(state);

    if (updated.contains(path)) {
      updated.remove(path);
    } else {
      updated.add(path);
    }

    state = updated;
    await _persist();
  }

  Future<void> clear() async {
    state = <String>{};
    await _persist();
  }
}