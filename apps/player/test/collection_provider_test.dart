import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:player/providers/most_played_provider.dart';
import 'package:player/providers/recent_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Recently Played records repeated playback events', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(recentProvider.notifier);
    notifier.record('/music/one.mp3');
    notifier.record('/music/one.mp3');

    expect(container.read(recentProvider), [
      '/music/one.mp3',
      '/music/one.mp3',
    ]);
  });

  test('Most Played aggregates playback counts per song', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(mostPlayedProvider.notifier);
    notifier.record('/music/one.mp3');
    notifier.record('/music/one.mp3');

    expect(container.read(mostPlayedProvider), {'/music/one.mp3': 2});
  });
}