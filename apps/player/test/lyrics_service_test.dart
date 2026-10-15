import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:player/services/lyrics_service.dart';
import 'package:player/services/lrclib_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores synced lyrics and returns them from cache offline', () async {
    SharedPreferences.setMockInitialValues({});
    var requestCount = 0;
    final online = LyricsService(
      lrclib: LrcLibService(
        client: MockClient((request) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'syncedLyrics': '[00:01.00]First line\n[00:02.00]Second line',
            }),
            200,
          );
        }),
      ),
    );

    final downloaded = await online.loadLyrics(
      title: 'Example',
      artist: 'Artist',
      trackId: '/music/example.mp3',
    );
    expect(downloaded?.lines, hasLength(2));
    expect(downloaded?.cached, isFalse);

    final offline = LyricsService(
      lrclib: LrcLibService(
        client: MockClient((_) async {
          requestCount++;
          throw StateError('Network should not be needed for cached lyrics');
        }),
      ),
    );
    final cached = await offline.loadLyrics(
      title: 'Example',
      artist: 'Artist',
      trackId: '/music/example.mp3',
    );

    expect(cached?.lines, hasLength(2));
    expect(cached?.cached, isTrue);
    expect(requestCount, 1);
  });

  test('uses LRCLIB word-timed Lyricsfile when available', () async {
    SharedPreferences.setMockInitialValues({});
    Uri? requestedUri;
    final service = LyricsService(
      lrclib: LrcLibService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'syncedLyrics': '[00:01.00]Hello world!',
              'hasWordSync': true,
              'lyricsfile': '''
version: '1.0'
lines:
  - text: 'Hello world!'
    start_ms: 1000
    words:
      - text: 'Hello '
        start_ms: 1100
      - text: 'world!'
        start_ms: 1500
''',
            }),
            200,
          );
        }),
      ),
    );

    final lyrics = await service.loadLyrics(
      title: 'Example',
      artist: 'Artist',
      album: 'Album',
      duration: const Duration(seconds: 180),
    );

    expect(lyrics?.hasWordSync, isTrue);
    expect(lyrics?.lines.single.words, hasLength(2));
    expect(requestedUri?.queryParameters['album_name'], 'Album');
    expect(requestedUri?.queryParameters['duration'], '180');
  });

  test(
    'falls back to line-timed lyrics when word timings are absent',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = LyricsService(
        lrclib: LrcLibService(
          client: MockClient((_) async {
            return http.Response(
              jsonEncode({
                'syncedLyrics': '[00:01.00]Line fallback only',
                'hasWordSync': false,
                'lyricsfile': "version: '1.0'\nlines:\n  - text: 'Plain'\n",
              }),
              200,
            );
          }),
        ),
      );

      final lyrics = await service.loadLyrics(
        title: 'Fallback',
        artist: 'Artist',
      );
      expect(lyrics?.lines.single.text, 'Line fallback only');
      expect(lyrics?.hasWordSync, isFalse);
    },
  );
}
