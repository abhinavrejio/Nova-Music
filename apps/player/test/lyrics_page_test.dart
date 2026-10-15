import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/lyrics/lyrics_page.dart';
import 'package:player/features/lyrics/lyrics_provider.dart';
import 'package:player/models/lyric_line.dart';
import 'package:player/models/lyrics.dart';
import 'package:player/providers/audio/audio_player_provider.dart';
import 'package:player/providers/playback/playback_provider.dart';
import 'package:player/services/audio_player_service.dart';

class _FakeAudioPlayerService extends AudioPlayerService {
  Duration? soughtTo;

  @override
  Future<void> seek(Duration position) async {
    soughtTo = position;
  }
}

void main() {
  testWidgets('shows timed lyrics and seeks when a line is selected', (
    tester,
  ) async {
    final audio = _FakeAudioPlayerService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lyricsProvider.overrideWith(
            (ref, query) async => Lyrics(
              title: query.title,
              artist: query.artist,
              synced: true,
              lines: const [
                LyricLine(time: Duration(seconds: 1), text: 'First line'),
                LyricLine(time: Duration(seconds: 3), text: 'Second line'),
              ],
            ),
          ),
          positionProvider.overrideWith(
            (ref) => Stream.value(const Duration(seconds: 3)),
          ),
          audioPlayerProvider.overrideWithValue(audio),
        ],
        child: const MaterialApp(
          home: LyricsPage(title: 'Test Track', artist: 'Test Artist'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('First line'), findsOneWidget);
    expect(find.text('Second line'), findsOneWidget);
    await tester.tap(find.text('First line'));
    expect(audio.soughtTo, const Duration(seconds: 1));
  });
}
