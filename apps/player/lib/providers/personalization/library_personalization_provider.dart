import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const librarySectionNames = <String>[
  'Collections',
  'Songs',
  'Albums',
  'Artists',
  'Genres',
  'Folders',
  'Playlists',
];

class LibraryPersonalizationNotifier extends Notifier<Set<String>> {
  static const _key = 'library_visible_sections';
  bool _changedLocally = false;

  @override
  Set<String> build() {
    _load();
    return librarySectionNames.toSet();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (!_changedLocally && saved != null) state = saved.toSet();
  }

  void toggle(String section) {
    _changedLocally = true;
    final next = {...state};
    if (!next.add(section)) next.remove(section);
    state = next;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(
        _key,
        librarySectionNames.where(state.contains).toList(),
      ),
    );
  }

  void restoreDefaults() {
    _changedLocally = true;
    state = librarySectionNames.toSet();
    SharedPreferences.getInstance().then((prefs) => prefs.remove(_key));
  }
}

final libraryPersonalizationProvider =
    NotifierProvider<LibraryPersonalizationNotifier, Set<String>>(
      LibraryPersonalizationNotifier.new,
    );
