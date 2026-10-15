import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/player/widgets/mini_player.dart';
import 'package:player/features/player/player_page.dart';
import 'package:player/features/lyrics/lyrics_provider.dart';
import 'package:player/models/lyric_line.dart';
import 'package:player/models/lyrics.dart';
import 'package:player/models/current_song.dart';
import 'package:player/providers/audio/audio_player_provider.dart';
import 'package:player/providers/playback/current_song_provider.dart';
import 'package:player/providers/playback/playback_provider.dart';
import 'package:player/services/audio_player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PlayingAudioService extends AudioPlayerService {
  final controller = StreamController<bool>.broadcast();
  bool playing = false;
  int toggleCount = 0;

  @override
  Stream<bool> get playingStream => controller.stream;

  @override
  bool get isPlaying => playing;

  @override
  Future<void> togglePlayPause() async {
    toggleCount++;
    playing = !playing;
    controller.add(playing);
  }
}

class _CurrentSongNotifier extends CurrentSongNotifier {
  @override
  CurrentSong? build() => const CurrentSong(
    path: '/music/song.mp3',
    title: 'Test Song',
    artist: 'Test Artist',
    album: 'Test Album',
    duration: Duration(minutes: 3),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('mini-player updates when play and pause are tapped', (
    tester,
  ) async {
    final audio = _PlayingAudioService();
    addTearDown(audio.controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerProvider.overrideWithValue(audio),
          currentSongProvider.overrideWith(_CurrentSongNotifier.new),
        ],
        child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
      ),
    );
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('mini-player track area opens Now Playing', (tester) async {
    final audio = _PlayingAudioService();
    addTearDown(audio.controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerProvider.overrideWithValue(audio),
          currentSongProvider.overrideWith(_CurrentSongNotifier.new),
        ],
        child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
      ),
    );

    await tester.tap(find.text('Test Song'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlayerPage), findsOneWidget);
    expect(find.text('Now Playing'), findsNothing);
  });

  testWidgets('mini-player lyrics opens Now Playing with lyrics visible', (
    tester,
  ) async {
    final audio = _PlayingAudioService();
    addTearDown(audio.controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioPlayerProvider.overrideWithValue(audio),
          currentSongProvider.overrideWith(_CurrentSongNotifier.new),
          lyricsProvider.overrideWith(
            (ref, query) async => Lyrics(
              title: query.title,
              artist: query.artist,
              synced: true,
              source: 'Test',
              lines: const [
                LyricLine(time: Duration.zero, text: 'Test lyric line'),
              ],
            ),
          ),
          positionProvider.overrideWith((ref) => Stream.value(Duration.zero)),
        ],
        child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
      ),
    );

    await tester.tap(find.byTooltip('Open Now Playing with lyrics'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlayerPage), findsOneWidget);
    expect(find.byTooltip('Hide lyrics'), findsOneWidget);
    expect(find.text('LYRICS'), findsNothing);
    expect(find.text('Test lyric line'), findsOneWidget);

    if (Platform.isWindows) {
      final requestedModes = <bool>[];
      const windowChannel = MethodChannel('nova/window');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowChannel, (call) async {
            if (call.method == 'setFullscreen') {
              requestedModes.add(call.arguments as bool);
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(windowChannel, null),
      );

      await tester.ensureVisible(find.byTooltip('Full screen'));
      await tester.tap(find.byTooltip('Full screen'));
      await tester.pump();
      expect(requestedModes, [true]);
      expect(find.byTooltip('Exit full screen'), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Exit full screen'));
      await tester.tap(find.byTooltip('Exit full screen'));
      await tester.pump();
      expect(requestedModes, [true, false]);
    }

    await tester.ensureVisible(find.byTooltip('Hide lyrics'));
    await tester.tap(find.byTooltip('Hide lyrics'));
    await tester.pump();
    expect(find.byTooltip('Show lyrics'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Show lyrics'));
    await tester.tap(find.byTooltip('Show lyrics'));
    await tester.pump();
    expect(find.byTooltip('Hide lyrics'), findsOneWidget);
  });
}
