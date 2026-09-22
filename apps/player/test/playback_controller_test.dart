import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:player/models/current_song.dart';
import 'package:player/providers/audio/audio_player_provider.dart';
import 'package:player/providers/playback/current_song_provider.dart';
import 'package:player/providers/playback/playback_controller_provider.dart';
import 'package:player/providers/playback/playback_mode_provider.dart';
import 'package:player/providers/playback/queue_index_provider.dart';
import 'package:player/providers/playback/queue_provider.dart';
import 'package:player/services/audio_player_service.dart';

class FakeAudioPlayerService extends AudioPlayerService {
  String? lastOpenedPath;

  @override
  Future<void> openFile(String path, {bool play = true}) async {
    lastOpenedPath = path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const songs = [
    CurrentSong(
      path: '/music/one.mp3',
      title: 'One',
      artist: 'Artist',
      album: 'Album',
      duration: Duration(minutes: 3),
    ),
    CurrentSong(
      path: '/music/two.mp3',
      title: 'Two',
      artist: 'Artist',
      album: 'Album',
      duration: Duration(minutes: 3),
    ),
  ];

  ProviderContainer createContainer(FakeAudioPlayerService audio) {
    final container = ProviderContainer(
      overrides: [
        audioPlayerProvider.overrideWithValue(audio),
      ],
    );
    container.read(queueProvider.notifier).setQueue(songs);
    return container;
  }

  test('repeat one reopens the current song on completion', () async {
    final audio = FakeAudioPlayerService();
    final container = createContainer(audio);
    addTearDown(container.dispose);

    container.read(queueIndexProvider.notifier).setIndex(1);
    container.read(currentSongProvider.notifier).setSong(songs[1]);
    container.read(repeatModeProvider.notifier).nextMode();
    container.read(repeatModeProvider.notifier).nextMode();

    await container.read(playbackControllerProvider).next(fromCompletion: true);

    expect(container.read(queueIndexProvider), 1);
    expect(container.read(currentSongProvider), songs[1]);
    expect(audio.lastOpenedPath, songs[1].path);
  });

  test('repeat all wraps to the first song on completion', () async {
    final audio = FakeAudioPlayerService();
    final container = createContainer(audio);
    addTearDown(container.dispose);

    container.read(queueIndexProvider.notifier).setIndex(1);
    container.read(repeatModeProvider.notifier).nextMode();

    await container.read(playbackControllerProvider).next(fromCompletion: true);

    expect(container.read(queueIndexProvider), 0);
    expect(container.read(currentSongProvider), songs[0]);
    expect(audio.lastOpenedPath, songs[0].path);
  });

  test('repeat off stops at the end on completion', () async {
    final audio = FakeAudioPlayerService();
    final container = createContainer(audio);
    addTearDown(container.dispose);

    container.read(queueIndexProvider.notifier).setIndex(1);
    container.read(currentSongProvider.notifier).setSong(songs[1]);

    await container.read(playbackControllerProvider).next(fromCompletion: true);

    expect(container.read(queueIndexProvider), 1);
    expect(container.read(currentSongProvider), songs[1]);
    expect(audio.lastOpenedPath, isNull);
  });
}