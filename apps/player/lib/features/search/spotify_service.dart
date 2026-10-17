import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'music_service.dart';
import 'oauth_token_storage.dart';
import 'streaming_provider_credentials.dart';

const spotifyPlaybackScopes = <String>{
  'user-read-playback-state',
  'user-modify-playback-state',
};

/// Spotify's public client ID is not a secret. The PKCE verifier and OAuth
/// tokens remain ephemeral/protected; no client secret is accepted here.
class SpotifyOAuthService {
  SpotifyOAuthService({
    required this.clientId,
    required this.tokenStorage,
    http.Client? client,
    Future<bool> Function(Uri)? launchAuthorization,
  }) : _client = client ?? http.Client(),
       _launchAuthorization = launchAuthorization ?? _launchInBrowser;

  final String clientId;
  final OAuthTokenStorage tokenStorage;
  final http.Client _client;
  final Future<bool> Function(Uri) _launchAuthorization;

  Future<OAuthTokens?> restoreSession() async {
    final tokens = await tokenStorage.read(MusicServiceId.spotify);
    if (tokens == null) return null;
    try {
      return await _ensureFresh(tokens);
    } on SpotifyOAuthException {
      await tokenStorage.delete(MusicServiceId.spotify);
      return null;
    }
  }

  Future<OAuthTokens> connect() async {
    if (clientId.isEmpty) {
      throw const SpotifyOAuthException(
        'Spotify is not configured. Add SPOTIFY_CLIENT_ID to the local build.',
      );
    }
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      throw const SpotifyOAuthException(
        'Spotify sign-in currently needs a desktop loopback redirect. Configure an HTTPS app link for mobile or web.',
      );
    }

    final verifier = _randomUrlSafe(64);
    final challenge = base64Url
        .encode(sha256.convert(utf8.encode(verifier)).bytes)
        .replaceAll('=', '');
    final state = _randomUrlSafe(32);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirectUri = Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: server.port,
      path: '/callback',
    );
    final callbackCompleter = Completer<Uri>();
    final subscription = server.listen((request) async {
      if (request.uri.path != '/callback') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      request.response.headers.contentType = ContentType.html;
      request.response.write(
        '<!doctype html><meta charset="utf-8"><title>Nova Music</title>'
        '<p>You can return to Nova Music now.</p>',
      );
      await request.response.close();
      if (!callbackCompleter.isCompleted) {
        callbackCompleter.complete(request.uri);
      }
    });

    final authorizationUri = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri.toString(),
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'state': state,
      'scope': spotifyPlaybackScopes.join(' '),
    });

    try {
      if (!await _launchAuthorization(authorizationUri)) {
        throw const SpotifyOAuthException(
          'Could not open the Spotify sign-in page.',
        );
      }
      final callback = await callbackCompleter.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () => throw const SpotifyOAuthException(
          'Spotify sign-in timed out. Please try again.',
        ),
      );
      if (callback.queryParameters['state'] != state) {
        throw const SpotifyOAuthException(
          'Spotify sign-in state did not match. Please try again.',
        );
      }
      final error = callback.queryParameters['error'];
      if (error != null) {
        throw SpotifyOAuthException('Spotify sign-in was denied: $error.');
      }
      final code = callback.queryParameters['code'];
      if (code == null || code.isEmpty) {
        throw const SpotifyOAuthException(
          'Spotify did not return an authorization code.',
        );
      }

      final response = await _client.post(
        Uri.https('accounts.spotify.com', '/api/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri.toString(),
          'client_id': clientId,
          'code_verifier': verifier,
        },
      );
      final tokens = _tokensFromResponse(response, previous: null);
      await tokenStorage.write(MusicServiceId.spotify, tokens);
      return tokens;
    } finally {
      await subscription.cancel();
      await server.close(force: true);
    }
  }

  Future<void> disconnect() => tokenStorage.delete(MusicServiceId.spotify);

  Future<OAuthTokens?> currentTokens() async {
    final tokens = await tokenStorage.read(MusicServiceId.spotify);
    if (tokens == null) return null;
    try {
      return await _ensureFresh(tokens);
    } on SpotifyOAuthException {
      await disconnect();
      return null;
    }
  }

  Future<String?> accessToken() async => (await currentTokens())?.accessToken;

  Future<OAuthTokens> _ensureFresh(OAuthTokens tokens) async {
    final expiry = tokens.expiresAt;
    if (expiry == null ||
        expiry.isAfter(
          DateTime.now().toUtc().add(const Duration(seconds: 45)),
        )) {
      return tokens;
    }
    final refreshToken = tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const SpotifyOAuthException('Spotify sign-in has expired.');
    }
    final response = await _client.post(
      Uri.https('accounts.spotify.com', '/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
      },
    );
    final refreshed = _tokensFromResponse(response, previous: tokens);
    await tokenStorage.write(MusicServiceId.spotify, refreshed);
    return refreshed;
  }

  OAuthTokens _tokensFromResponse(
    http.Response response, {
    required OAuthTokens? previous,
  }) {
    if (response.statusCode != 200) {
      throw SpotifyOAuthException(
        'Spotify token request failed (HTTP ${response.statusCode}).',
      );
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic> || json['access_token'] is! String) {
      throw const SpotifyOAuthException('Spotify returned an invalid token.');
    }
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    final scopesValue = json['scope'] as String?;
    return OAuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? previous?.refreshToken,
      expiresAt: DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
      scopes: scopesValue == null || scopesValue.trim().isEmpty
          ? previous?.scopes ?? const {}
          : scopesValue.split(' ').where((scope) => scope.isNotEmpty).toSet(),
    );
  }

  static String _randomUrlSafe(int length) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Future<bool> _launchInBrowser(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

class SpotifyOAuthException implements Exception {
  const SpotifyOAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SpotifyConnectionController extends AsyncNotifier<OAuthTokens?> {
  SpotifyOAuthService get _service => ref.read(spotifyOAuthServiceProvider);

  @override
  Future<OAuthTokens?> build() =>
      ref.watch(spotifyOAuthServiceProvider).restoreSession();

  Future<void> connect() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_service.connect);
  }

  Future<void> disconnect() async {
    await _service.disconnect();
    state = const AsyncData(null);
  }

  Future<String?> currentAccessToken() => _service.accessToken();

  Future<OAuthTokens?> currentTokens() => _service.currentTokens();
}

final spotifyOAuthServiceProvider = Provider<SpotifyOAuthService>((ref) {
  return SpotifyOAuthService(
    clientId:
        ref.watch(spotifyClientIdProvider).value ??
        const String.fromEnvironment('SPOTIFY_CLIENT_ID'),
    tokenStorage: ref.watch(oauthTokenStorageProvider),
  );
});

final spotifyConnectionProvider =
    AsyncNotifierProvider<SpotifyConnectionController, OAuthTokens?>(
      SpotifyConnectionController.new,
    );

final spotifyMusicCatalogServiceProvider = Provider<MusicCatalogService>((ref) {
  final connection = ref.watch(spotifyConnectionProvider);
  final clientId =
      ref.watch(spotifyClientIdProvider).value ??
      const String.fromEnvironment('SPOTIFY_CLIENT_ID');
  final token = connection.when(
    data: (tokens) => tokens?.accessToken,
    error: (_, _) => null,
    loading: () => null,
  );
  return SpotifyCatalogService(
    clientId: clientId,
    accessToken: token,
    accessTokenProvider: () =>
        ref.read(spotifyConnectionProvider.notifier).currentAccessToken(),
  );
});

class SpotifyCatalogService implements MusicCatalogService {
  SpotifyCatalogService({
    required this.clientId,
    required this.accessToken,
    required this.accessTokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String clientId;
  final String? accessToken;
  final Future<String?> Function() accessTokenProvider;
  final http.Client _client;

  @override
  MusicServiceStatus get status => MusicServiceStatus(
    service: MusicServiceId.spotify,
    connection: clientId.isEmpty
        ? MusicServiceConnection.needsSetup
        : accessToken == null
        ? MusicServiceConnection.disconnected
        : MusicServiceConnection.connected,
    message: clientId.isEmpty
        ? 'Add a Spotify client ID to the local build.'
        : accessToken == null
        ? 'Connect a Spotify account to search its catalog preference.'
        : 'Spotify account connected.',
  );

  @override
  Future<List<MusicSearchResult>> search(String query) async {
    final term = query.trim();
    if (term.isEmpty || clientId.isEmpty) return const [];
    final token = await accessTokenProvider();
    if (token == null) return const [];
    final response = await _client.get(
      Uri.https('api.spotify.com', '/v1/search', {
        'q': term,
        'type': 'track',
        // Spotify's current Development Mode maximum is 10.
        'limit': '10',
      }),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw SpotifySearchException(response.statusCode);
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) return const [];
    final tracks = json['tracks'];
    final items = tracks is Map<String, dynamic> ? tracks['items'] : null;
    if (items is! List) return const [];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          if (_resultFromJson(item) case final result?) result,
    ];
  }

  MusicSearchResult? _resultFromJson(Map<String, dynamic> item) {
    final name = item['name'];
    final id = item['id'];
    final artists = item['artists'];
    final album = item['album'];
    final externalUrls = item['external_urls'];
    if (name is! String || id is! String || artists is! List) return null;
    final artistNames = artists
        .whereType<Map<String, dynamic>>()
        .map((artist) => artist['name'])
        .whereType<String>()
        .join(', ');
    final albumMap = album is Map<String, dynamic> ? album : const {};
    final images = albumMap['images'];
    final firstImage = images is List && images.isNotEmpty
        ? images.first
        : null;
    final artwork = firstImage is Map<String, dynamic>
        ? firstImage['url'] as String?
        : null;
    final urls = externalUrls is Map<String, dynamic> ? externalUrls : const {};
    return MusicSearchResult(
      service: MusicServiceId.spotify,
      id: id,
      title: name,
      artist: artistNames,
      subtitle: albumMap['name'] as String? ?? '',
      url: urls['spotify'] as String? ?? 'https://open.spotify.com/track/$id',
      artworkUrl: artwork,
    );
  }
}

class SpotifySearchException implements Exception {
  const SpotifySearchException(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'Spotify search failed (HTTP $statusCode).';
}

/// Controls a user's existing Spotify Connect devices. Nova never receives
/// or re-streams Spotify audio; playback stays in Spotify's own client.
class SpotifyRemotePlaybackService {
  SpotifyRemotePlaybackService({
    required this.tokensProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Future<OAuthTokens?> Function() tokensProvider;
  final http.Client _client;

  Future<List<SpotifyPlaybackDevice>> devices() async {
    final response = await _request(
      'GET',
      Uri.https('api.spotify.com', '/v1/me/player/devices'),
    );
    final json = _decode(response);
    final items = json is Map<String, dynamic> ? json['devices'] : null;
    if (items is! List) return const [];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          if (SpotifyPlaybackDevice.fromJson(item) case final device?) device,
    ];
  }

  Future<SpotifyPlaybackSnapshot?> currentPlayback() async {
    final response = await _request(
      'GET',
      Uri.https('api.spotify.com', '/v1/me/player'),
      allowNoContent: true,
    );
    if (response.statusCode == 204 || response.body.trim().isEmpty) {
      return null;
    }
    final json = _decode(response);
    return json is Map<String, dynamic>
        ? SpotifyPlaybackSnapshot.fromJson(json)
        : null;
  }

  Future<void> playTrack(String trackId, {String? deviceId}) async {
    final uri = Uri.https(
      'api.spotify.com',
      '/v1/me/player/play',
      deviceId == null ? null : {'device_id': deviceId},
    );
    await _request(
      'PUT',
      uri,
      body: {
        'uris': ['spotify:track:$trackId'],
      },
    );
  }

  Future<void> resume({String? deviceId}) async {
    final uri = Uri.https(
      'api.spotify.com',
      '/v1/me/player/play',
      deviceId == null ? null : {'device_id': deviceId},
    );
    await _request('PUT', uri, body: const {});
  }

  Future<void> pause({String? deviceId}) async {
    final uri = Uri.https(
      'api.spotify.com',
      '/v1/me/player/pause',
      deviceId == null ? null : {'device_id': deviceId},
    );
    await _request('PUT', uri);
  }

  Future<void> next({String? deviceId}) =>
      _command('POST', '/v1/me/player/next', deviceId: deviceId);

  Future<void> previous({String? deviceId}) =>
      _command('POST', '/v1/me/player/previous', deviceId: deviceId);

  Future<void> seek(Duration position, {String? deviceId}) async {
    final uri = Uri.https('api.spotify.com', '/v1/me/player/seek', {
      'position_ms': '${position.inMilliseconds.clamp(0, 2147483647)}',
      if (deviceId != null) 'device_id': deviceId,
    });
    await _request('PUT', uri);
  }

  Future<void> transferPlayback(String deviceId, {bool play = true}) async {
    await _request(
      'PUT',
      Uri.https('api.spotify.com', '/v1/me/player'),
      body: {
        'device_ids': [deviceId],
        'play': play,
      },
    );
  }

  Future<void> _command(String method, String path, {String? deviceId}) async {
    await _request(
      method,
      Uri.https('api.spotify.com', path, {
        if (deviceId != null) 'device_id': deviceId,
      }),
    );
  }

  Future<http.Response> _request(
    String method,
    Uri uri, {
    Map<String, Object?>? body,
    bool allowNoContent = false,
  }) async {
    final tokens = await tokensProvider();
    if (tokens == null) {
      throw const SpotifyRemotePlaybackException(
        'Connect Spotify first to control playback.',
      );
    }
    if (!tokens.scopes.containsAll(spotifyPlaybackScopes)) {
      throw const SpotifyRemotePlaybackException(
        'Reconnect Spotify and approve playback control to use these controls.',
      );
    }

    final request = http.Request(method, uri)
      ..headers['Authorization'] = 'Bearer ${tokens.accessToken}'
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    if (allowNoContent && response.statusCode == 204) return response;
    if (response.statusCode == 404) {
      throw const SpotifyRemotePlaybackException(
        'No active Spotify device was found. Open Spotify on a device, then refresh.',
      );
    }
    if (response.statusCode == 403) {
      throw const SpotifyRemotePlaybackException(
        'Spotify denied playback control. Check the account plan and reconnect permissions.',
      );
    }
    if (response.statusCode == 429) {
      throw const SpotifyRemotePlaybackException(
        'Spotify is rate limiting requests. Wait a moment and try again.',
      );
    }
    throw SpotifyRemotePlaybackException(
      'Spotify playback request failed (HTTP ${response.statusCode}).',
    );
  }

  Object? _decode(http.Response response) {
    if (response.statusCode == 204 || response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const SpotifyRemotePlaybackException(
        'Spotify returned an unreadable playback response.',
      );
    }
  }
}

class SpotifyPlaybackDevice {
  const SpotifyPlaybackDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.isRestricted,
    this.volumePercent,
  });

  final String id;
  final String name;
  final String type;
  final bool isActive;
  final bool isRestricted;
  final int? volumePercent;

  static SpotifyPlaybackDevice? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! String || name is! String) return null;
    return SpotifyPlaybackDevice(
      id: id,
      name: name,
      type: json['type'] as String? ?? 'Device',
      isActive: json['is_active'] as bool? ?? false,
      isRestricted: json['is_restricted'] as bool? ?? false,
      volumePercent: (json['volume_percent'] as num?)?.toInt(),
    );
  }
}

class SpotifyPlaybackSnapshot {
  const SpotifyPlaybackSnapshot({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkUrl,
    required this.duration,
    required this.position,
    required this.isPlaying,
    required this.deviceName,
  });

  final String? trackId;
  final String title;
  final String artist;
  final String album;
  final String? artworkUrl;
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final String? deviceName;

  static SpotifyPlaybackSnapshot? fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is! Map<String, dynamic>) return null;
    final title = item['name'];
    if (title is! String) return null;
    final artists = item['artists'];
    final artist = artists is List
        ? artists
              .whereType<Map<String, dynamic>>()
              .map((entry) => entry['name'])
              .whereType<String>()
              .join(', ')
        : '';
    final albumValue = item['album'];
    final album = albumValue is Map<String, dynamic>
        ? albumValue
        : const <String, dynamic>{};
    final images = album['images'];
    final firstImage = images is List && images.isNotEmpty
        ? images.first
        : null;
    final artworkUrl = firstImage is Map<String, dynamic>
        ? firstImage['url'] as String?
        : null;
    final durationMs = (item['duration_ms'] as num?)?.toInt() ?? 0;
    final positionMs = (json['progress_ms'] as num?)?.toInt() ?? 0;
    final device = json['device'];
    return SpotifyPlaybackSnapshot(
      trackId: item['id'] as String?,
      title: title,
      artist: artist,
      album: album['name'] as String? ?? '',
      artworkUrl: artworkUrl,
      duration: Duration(milliseconds: durationMs),
      position: Duration(milliseconds: positionMs.clamp(0, durationMs)),
      isPlaying: json['is_playing'] as bool? ?? false,
      deviceName: device is Map<String, dynamic>
          ? device['name'] as String?
          : null,
    );
  }
}

class SpotifyRemotePlaybackException implements Exception {
  const SpotifyRemotePlaybackException(this.message);
  final String message;

  @override
  String toString() => message;
}

final spotifyRemotePlaybackServiceProvider =
    Provider<SpotifyRemotePlaybackService>((ref) {
      return SpotifyRemotePlaybackService(
        tokensProvider: () =>
            ref.read(spotifyConnectionProvider.notifier).currentTokens(),
      );
    });

final spotifyCurrentPlaybackProvider = StreamProvider<SpotifyPlaybackSnapshot?>(
  (ref) async* {
    final tokens = ref
        .watch(spotifyConnectionProvider)
        .when(
          data: (value) => value,
          error: (_, _) => null,
          loading: () => null,
        );
    if (tokens == null) return;
    final service = ref.watch(spotifyRemotePlaybackServiceProvider);
    while (true) {
      try {
        yield await service.currentPlayback();
      } catch (_) {
        yield null;
      }
      await Future<void>.delayed(const Duration(seconds: 8));
    }
  },
);
