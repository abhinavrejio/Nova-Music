import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePersonalizationNotifier extends Notifier<List<String>> {
  static const List<String> _defaultSections = [
    'Continue Listening',
    'Quick Collections',
    'Recently Played',
    'Albums',
    'Artists',
    'Playlists',
    'Genres',
    'Favorites',
    'Downloads',
  ];

  @override
  List<String> build() {
    return List<String>.from(_defaultSections);
  }

  void reorder(int oldIndex, int newIndex) {
    final updated = List<String>.from(state);

    if (oldIndex < newIndex) {
      newIndex--;
    }

    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    state = updated;
  }

  void restoreDefaults() {
    state = List<String>.from(_defaultSections);
  }
}

final homePersonalizationProvider =
    NotifierProvider<HomePersonalizationNotifier, List<String>>(
  HomePersonalizationNotifier.new,
);