import 'dart:convert';

import 'package:http/http.dart' as http;

class LrcLibService {
  static const _baseUrl = 'https://lrclib.net/api';

  Future<Map<String, dynamic>?> getLyrics({
    required String artist,
    required String title,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/get?artist_name=${Uri.encodeComponent(artist)}'
      '&track_name=${Uri.encodeComponent(title)}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    return jsonDecode(response.body);
  }
}