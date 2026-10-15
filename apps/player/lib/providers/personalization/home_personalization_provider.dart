import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/personalization/home_section.dart';

class HomePersonalizationNotifier extends Notifier<List<HomeSection>> {
  static const _orderKey = 'home_section_order';
  static const _visibilityKey = 'home_section_visibility';
  bool _changedLocally = false;

  @override
  List<HomeSection> build() {
    final defaults = _defaults();
    _load(defaults);
    return defaults;
  }

  Future<void> _load(List<HomeSection> defaults) async {
    final prefs = await SharedPreferences.getInstance();
    final order = prefs.getStringList(_orderKey);
    final storedVisibility = prefs.getStringList(_visibilityKey);
    final visibility = storedVisibility?.toSet() ?? {};
    if (_changedLocally || (order == null && storedVisibility == null)) return;
    final byType = {for (final section in defaults) section.type.name: section};
    final ordered = <HomeSection>[];
    for (final name in [...?order, ...byType.keys]) {
      final section = byType.remove(name);
      if (section != null) {
        ordered.add(
          section.copyWith(
            visible: storedVisibility == null || visibility.contains(name),
          ),
        );
      }
    }
    state = ordered;
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    _changedLocally = true;
    state = list;
    _persist();
  }

  void toggle(HomeSectionType type) {
    _changedLocally = true;
    state = [
      for (final section in state)
        if (section.type == type)
          section.copyWith(visible: !section.visible)
        else
          section,
    ];
    _persist();
  }

  void restoreDefaults() {
    _changedLocally = true;
    state = _defaults();
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_orderKey);
      prefs.remove(_visibilityKey);
    });
  }

  List<HomeSection> _defaults() => const [
    HomeSection(
      type: HomeSectionType.continueListening,
      title: 'Continue Listening',
    ),
    HomeSection(
      type: HomeSectionType.quickCollections,
      title: 'Quick Collections',
    ),
    HomeSection(type: HomeSectionType.recentlyPlayed, title: 'Recently Played'),
    HomeSection(type: HomeSectionType.albums, title: 'Albums'),
    HomeSection(type: HomeSectionType.artists, title: 'Artists'),
    HomeSection(type: HomeSectionType.playlists, title: 'Playlists'),
    HomeSection(type: HomeSectionType.genres, title: 'Genres'),
    HomeSection(type: HomeSectionType.favorites, title: 'Favorites'),
    HomeSection(type: HomeSectionType.downloads, title: 'Downloads'),
  ];

  void _persist() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(_orderKey, state.map((s) => s.type.name).toList());
      prefs.setStringList(
        _visibilityKey,
        state.where((s) => s.visible).map((s) => s.type.name).toList(),
      );
    });
  }
}

final homePersonalizationProvider =
    NotifierProvider<HomePersonalizationNotifier, List<HomeSection>>(
      HomePersonalizationNotifier.new,
    );
