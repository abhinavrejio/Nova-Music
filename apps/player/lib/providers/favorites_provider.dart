import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  bool isFavorite(String path) {
    return state.contains(path);
  }

  void toggle(String path) {
    final updated = Set<String>.from(state);

    if (updated.contains(path)) {
      updated.remove(path);
    } else {
      updated.add(path);
    }

    state = updated;
  }

  void clear() {
    state = <String>{};
  }
}