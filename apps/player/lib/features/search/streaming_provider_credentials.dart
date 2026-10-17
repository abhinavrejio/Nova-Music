import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/lyrics_credentials_service.dart';

final spotifyClientIdProvider = FutureProvider<String>((ref) async {
  try {
    return await LyricsCredentialsService.instance.readSpotifyClientId() ??
        const String.fromEnvironment('SPOTIFY_CLIENT_ID');
  } catch (_) {
    return const String.fromEnvironment('SPOTIFY_CLIENT_ID');
  }
});

final appleMusicDeveloperTokenProvider = FutureProvider<String>((ref) async {
  try {
    return await LyricsCredentialsService.instance
            .readAppleMusicDeveloperToken() ??
        const String.fromEnvironment('APPLE_MUSIC_DEVELOPER_TOKEN');
  } catch (_) {
    return const String.fromEnvironment('APPLE_MUSIC_DEVELOPER_TOKEN');
  }
});
