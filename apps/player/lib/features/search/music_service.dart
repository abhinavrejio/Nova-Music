import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apple_music_catalog_service.dart';

/// A service that can contribute catalog results to Nova's search screen.
///
/// Results remain attributed to their service. Implementations must not expose
/// playable media URLs; providers generally grant catalog metadata or playback
/// hand-off, not rights to proxy their audio through Nova.
enum MusicServiceId { appleMusic, spotify, youtubeMusic }

enum MusicServiceConnection {
  disconnected,
  connected,
  catalogReady,
  needsSetup,
  unsupported,
}

class MusicServiceStatus {
  const MusicServiceStatus({
    required this.service,
    required this.connection,
    required this.message,
  });

  final MusicServiceId service;
  final MusicServiceConnection connection;
  final String message;
}

class MusicSearchResult {
  const MusicSearchResult({
    required this.service,
    required this.id,
    required this.title,
    required this.artist,
    required this.subtitle,
    required this.url,
    this.artworkUrl,
  });

  final MusicServiceId service;
  final String id;
  final String title;
  final String artist;
  final String subtitle;
  final String url;
  final String? artworkUrl;
}

abstract interface class MusicCatalogService {
  MusicServiceStatus get status;
  Future<List<MusicSearchResult>> search(String query);
}

/// Explicit unavailable state for YouTube Music. YouTube Data API search
/// returns videos and does not authenticate or search a YouTube Music library.
class UnsupportedYouTubeMusicService implements MusicCatalogService {
  @override
  MusicServiceStatus get status => const MusicServiceStatus(
    service: MusicServiceId.youtubeMusic,
    connection: MusicServiceConnection.unsupported,
    message: 'YouTube Music has no supported public catalog integration.',
  );

  @override
  Future<List<MusicSearchResult>> search(String query) async => const [];
}

final musicCatalogServicesProvider = Provider<List<MusicCatalogService>>(
  (ref) => [
    AppleMusicCatalogService(
      developerToken: const String.fromEnvironment(
        'APPLE_MUSIC_DEVELOPER_TOKEN',
      ),
    ),
    const SpotifyCatalogService(),
    UnsupportedYouTubeMusicService(),
  ],
);

/// Spotify OAuth is intentionally not inferred from a client ID. The app needs
/// a registered redirect URI and PKCE flow before a user is connected.
class SpotifyCatalogService implements MusicCatalogService {
  const SpotifyCatalogService();

  @override
  MusicServiceStatus get status => const MusicServiceStatus(
    service: MusicServiceId.spotify,
    connection: MusicServiceConnection.needsSetup,
    message: 'Add a Spotify client ID and OAuth redirect URI to connect.',
  );

  @override
  Future<List<MusicSearchResult>> search(String query) async => const [];
}
