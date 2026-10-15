import 'dart:convert';

import 'package:http/http.dart' as http;

class LrcLibService {
  LrcLibService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>?> getLyrics({
    required String artist,
    required String title,
    String? album,
    Duration? duration,
  }) async {
    final query = <String, String>{'artist_name': artist, 'track_name': title};
    if (album != null && album.trim().isNotEmpty) {
      query['album_name'] = album;
    }
    if (duration != null && duration.inSeconds > 0) {
      query['duration'] = duration.inSeconds.toString();
    }
    final uri = Uri.https('lrclib.net', '/api/get', query);

    final response = await _client
        .get(
          uri,
          headers: const {'User-Agent': 'NovaMusic/1.0 (Flutter music player)'},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }
}
