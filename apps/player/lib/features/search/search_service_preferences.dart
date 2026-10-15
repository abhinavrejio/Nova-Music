import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'music_service.dart';

const _preferencesKey = 'music_search_services';

class SearchServicePreferences extends Notifier<Set<MusicServiceId>> {
  @override
  Set<MusicServiceId> build() {
    _load();
    // Keep the intended services selected. A service contributes results only
    // when it is configured and ready as well.
    return {MusicServiceId.appleMusic, MusicServiceId.spotify};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_preferencesKey);
    if (stored == null) return;
    final parsed = <MusicServiceId>{
      for (final value in stored)
        for (final service in MusicServiceId.values)
          if (service.name == value) service,
    };
    state = parsed;
  }

  void setEnabled(MusicServiceId service, bool enabled) {
    final next = {...state};
    if (enabled) {
      next.add(service);
    } else {
      next.remove(service);
    }
    state = next;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(
        _preferencesKey,
        next.map((service) => service.name).toList(),
      ),
    );
  }
}

final searchServicePreferencesProvider =
    NotifierProvider<SearchServicePreferences, Set<MusicServiceId>>(
      SearchServicePreferences.new,
    );
