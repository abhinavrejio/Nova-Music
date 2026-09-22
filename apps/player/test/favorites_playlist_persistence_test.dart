import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:player/providers/playlists/favorites_provider.dart';
import 'package:player/providers/playlists/playlist_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('favorites persist across provider containers', () async {
    final first = ProviderContainer();
    await first.read(favoritesProvider.notifier).toggle('/music/song-1.mp3');

    expect(first.read(favoritesProvider), {'/music/song-1.mp3'});

    final second = ProviderContainer();
    await second.read(favoritesProvider.notifier).load();

    expect(second.read(favoritesProvider), {'/music/song-1.mp3'});

    first.dispose();
    second.dispose();
  });

  test('playlists persist across provider containers', () async {
    final first = ProviderContainer();
    await first.read(playlistProvider.notifier).createPlaylist('Night Drive');

    expect(first.read(playlistProvider).length, 1);
    expect(first.read(playlistProvider).first.name, 'Night Drive');

    final second = ProviderContainer();
    await second.read(playlistProvider.notifier).load();

    expect(second.read(playlistProvider).length, 1);
    expect(second.read(playlistProvider).first.name, 'Night Drive');

    first.dispose();
    second.dispose();
  });
}
