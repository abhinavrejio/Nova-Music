import 'dart:convert';

import 'package:http/http.dart' as http;

import 'music_service.dart';

/// Searches Apple's public catalog. A developer token is required; a Music
/// User Token is additionally required for a person's library and is not
/// treated as interchangeable with this catalog-only integration.
class AppleMusicCatalogService implements MusicCatalogService {
  AppleMusicCatalogService({
    required this.developerToken,
    this.storefront = 'us',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String developerToken;
  final String storefront;
  final http.Client _client;

  @override
  MusicServiceStatus get status => MusicServiceStatus(
    service: MusicServiceId.appleMusic,
    connection: developerToken.isEmpty
        ? MusicServiceConnection.needsSetup
        : MusicServiceConnection.catalogReady,
    message: developerToken.isEmpty
        ? 'Apple Music catalog search needs a developer token.'
        : 'Apple Music catalog search is ready. Personal library access still needs Apple Music authorization.',
  );

  @override
  Future<List<MusicSearchResult>> search(String query) async {
    final term = query.trim();
    if (term.isEmpty || developerToken.isEmpty) return const [];

    final uri = Uri.https(
      'api.music.apple.com',
      '/v1/catalog/$storefront/search',
      {'term': term, 'types': 'songs', 'limit': '20'},
    );
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $developerToken'},
    );
    if (response.statusCode != 200) {
      throw AppleMusicSearchException(response.statusCode);
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) return const [];
    final results = json['results'];
    final songs = results is Map<String, dynamic> ? results['songs'] : null;
    final data = songs is Map<String, dynamic> ? songs['data'] : null;
    if (data is! List) return const [];

    return [
      for (final item in data)
        if (item is Map<String, dynamic>)
          if (_resultFromJson(item) case final result?) result,
    ];
  }

  MusicSearchResult? _resultFromJson(Map<String, dynamic> item) {
    final attributes = item['attributes'];
    if (attributes is! Map<String, dynamic>) return null;
    final title = attributes['name'];
    final artist = attributes['artistName'];
    if (title is! String || artist is! String) return null;

    final artwork = attributes['artwork'];
    final template = artwork is Map<String, dynamic>
        ? artwork['url'] as String?
        : null;
    final artworkUrl = template
        ?.replaceAll('{w}', '160')
        .replaceAll('{h}', '160');
    final album = attributes['albumName'] as String? ?? '';
    final url = attributes['url'] as String? ?? '';
    return MusicSearchResult(
      service: MusicServiceId.appleMusic,
      id: item['id'] as String? ?? url,
      title: title,
      artist: artist,
      subtitle: album,
      url: url,
      artworkUrl: artworkUrl,
    );
  }
}

class AppleMusicSearchException implements Exception {
  const AppleMusicSearchException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'Apple Music search failed (HTTP $statusCode).';
}
