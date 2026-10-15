import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/models/current_song.dart';
import 'package:player/providers/playback/current_song_provider.dart';
import 'package:player/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores last played path and persists the restore setting', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(currentSongProvider.notifier)
        .setSong(
          const CurrentSong(
            path: r'C:\Music\last-track.mp3',
            title: 'Last Track',
            artist: 'Artist',
            album: 'Album',
            duration: Duration(minutes: 3),
          ),
        );
    container.read(settingsProvider.notifier).setRestoreLastTrack(false);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(lastPlayedTrackStorageKey),
      r'C:\Music\last-track.mp3',
    );
    final settings = jsonDecode(
      preferences.getString('app_settings')!,
    ) as Map<String, dynamic>;
    expect(settings['restoreLastTrack'], isFalse);
  });
}
