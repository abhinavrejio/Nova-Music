import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apple_music_catalog_service.dart';
import 'music_service.dart';
import 'spotify_service.dart';
import 'streaming_provider_credentials.dart';

final musicCatalogServicesProvider = Provider<List<MusicCatalogService>>(
  (ref) => [
    AppleMusicCatalogService(
      developerToken:
          ref.watch(appleMusicDeveloperTokenProvider).value ??
          const String.fromEnvironment('APPLE_MUSIC_DEVELOPER_TOKEN'),
    ),
    ref.watch(spotifyMusicCatalogServiceProvider),
    UnsupportedYouTubeMusicService(),
  ],
);
