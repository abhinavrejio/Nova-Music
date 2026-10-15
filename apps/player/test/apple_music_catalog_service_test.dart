import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player/features/search/apple_music_catalog_service.dart';
import 'package:player/features/search/music_service.dart';

void main() {
  test('maps catalog songs and keeps Apple Music source identity', () async {
    Uri? requestedUri;
    String? authorization;
    final client = MockClient((request) async {
      requestedUri = request.url;
      authorization = request.headers['Authorization'];
      return http.Response(
        jsonEncode({
          'results': {
            'songs': {
              'data': [
                {
                  'id': '123',
                  'attributes': {
                    'name': 'Track',
                    'artistName': 'Artist',
                    'albumName': 'Album',
                    'url': 'https://music.apple.com/song/123',
                    'artwork': {'url': 'https://artwork.example/{w}x{h}bb.jpg'},
                  },
                },
              ],
            },
          },
        }),
        200,
      );
    });
    final service = AppleMusicCatalogService(
      developerToken: 'developer-token',
      storefront: 'in',
      client: client,
    );

    final results = await service.search('Track Name');

    expect(requestedUri?.path, '/v1/catalog/in/search');
    expect(requestedUri?.queryParameters['term'], 'Track Name');
    expect(authorization, 'Bearer developer-token');
    expect(results, hasLength(1));
    expect(results.single.service, MusicServiceId.appleMusic);
    expect(results.single.title, 'Track');
    expect(results.single.artist, 'Artist');
    expect(results.single.subtitle, 'Album');
    expect(results.single.artworkUrl, 'https://artwork.example/160x160bb.jpg');
  });

  test(
    'does not issue a request when no developer token is configured',
    () async {
      var requested = false;
      final service = AppleMusicCatalogService(
        developerToken: '',
        client: MockClient((_) async {
          requested = true;
          return http.Response('{}', 200);
        }),
      );

      expect(await service.search('song'), isEmpty);
      expect(requested, isFalse);
      expect(service.status.connection, MusicServiceConnection.needsSetup);
    },
  );

  test(
    'reports provider HTTP failures without returning false results',
    () async {
      final service = AppleMusicCatalogService(
        developerToken: 'developer-token',
        client: MockClient((_) async => http.Response('{}', 401)),
      );

      await expectLater(
        service.search('song'),
        throwsA(isA<AppleMusicSearchException>()),
      );
    },
  );

  test('YouTube Music is explicitly unsupported', () async {
    final service = UnsupportedYouTubeMusicService();

    expect(service.status.connection, MusicServiceConnection.unsupported);
    expect(await service.search('song'), isEmpty);
  });
}
