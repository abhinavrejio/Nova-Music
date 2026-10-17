import 'dart:convert';

import 'package:http/http.dart' as http;

class GeniusSongDetails {
  const GeniusSongDetails({
    required this.title,
    required this.artist,
    required this.url,
    this.album,
    this.releaseDate,
  });

  final String title;
  final String artist;
  final String url;
  final String? album;
  final String? releaseDate;
}

class GeniusService {
  GeniusService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<GeniusSongDetails?> findSong({
    required String accessToken,
    required String title,
    required String artist,
  }) async {
    final uri = Uri.https('api.genius.com', '/search', {
      'q': '$title $artist',
      'per_page': '10',
    });
    final response = await _client
        .get(uri, headers: {'Authorization': 'Bearer $accessToken'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['response'] is! Map) return null;
    final hits = (decoded['response'] as Map)['hits'];
    if (hits is! List || hits.isEmpty) return null;

    final candidates = <Map<String, dynamic>>[];
    for (final hit in hits) {
      final result = hit is Map ? hit['result'] : null;
      if (result is Map) candidates.add(Map<String, dynamic>.from(result));
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      int score(Map<String, dynamic> song) {
        final artistName = (song['primary_artist'] as Map?)?['name'];
        return (_normalize(song['title']) == _normalize(title) ? 2 : 0) +
            (_normalize(artistName) == _normalize(artist) ? 2 : 0);
      }

      return score(b).compareTo(score(a));
    });
    final result = candidates.first;
    final album = result['album'] is Map
        ? (result['album'] as Map)['name']?.toString()
        : null;
    final primaryArtist = result['primary_artist'] is Map
        ? (result['primary_artist'] as Map)['name']?.toString()
        : artist;
    final url = result['url']?.toString();
    if (url == null || url.isEmpty) return null;
    return GeniusSongDetails(
      title: result['title']?.toString() ?? title,
      artist: primaryArtist ?? artist,
      url: url,
      album: album,
      releaseDate: result['release_date_for_display']?.toString(),
    );
  }

  static String _normalize(Object? value) => (value?.toString() ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}
