import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lyric_line.dart';
import '../models/lyrics.dart';
import 'lyrics_parser.dart';

class MusixmatchService {
  MusixmatchService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _api = 'https://api.musixmatch.com/ws/1.1';

  Future<Lyrics?> loadWordSyncedLyrics({
    required String apiKey,
    required String title,
    required String artist,
    String? album,
    Duration? duration,
  }) async {
    final track = await _findTrack(
      apiKey: apiKey,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
    );
    if (track == null) return null;

    final commonTrackId = track['commontrack_id'];
    if (commonTrackId == null) return null;
    final commonId = commonTrackId.toString();

    final richSyncResponse = await _request('track.richsync.get', {
      'commontrack_id': commonId,
      'apikey': apiKey,
    });
    final richSync = _body(richSyncResponse)?['richsync'];
    final richSyncBody = richSync is Map ? richSync['richsync_body'] : null;
    if (richSyncBody is String && richSyncBody.isNotEmpty) {
      final parsed = _parseRichSync(richSyncBody);
      if (parsed.isNotEmpty) {
        return Lyrics(
          title: title,
          artist: artist,
          synced: true,
          source: 'Musixmatch',
          lines: parsed,
        );
      }
    }

    final subtitleResponse = await _request('track.subtitle.get', {
      'commontrack_id': commonId,
      'apikey': apiKey,
      'subtitle_format': 'lrc',
    });
    final subtitle = _body(subtitleResponse)?['subtitle'];
    final subtitleBody = subtitle is Map ? subtitle['subtitle_body'] : null;
    if (subtitleBody is String && subtitleBody.isNotEmpty) {
      final lines = LyricsParser.parse(subtitleBody);
      if (lines.isNotEmpty) {
        return Lyrics(
          title: title,
          artist: artist,
          synced: true,
          source: 'Musixmatch',
          lines: lines,
        );
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _findTrack({
    required String apiKey,
    required String title,
    required String artist,
    String? album,
    Duration? duration,
  }) async {
    final query = <String, String>{
      'q_track': title,
      'q_artist': artist,
      'page_size': '5',
      'f_has_lyrics': '1',
      'apikey': apiKey,
    };
    if (album?.trim().isNotEmpty == true) query['q_album'] = album!.trim();
    if (duration != null && duration.inSeconds > 0) {
      query['q_duration'] = duration.inSeconds.toString();
    }
    final response = await _request('track.search', query);
    final tracks = _body(response)?['track_list'];
    if (tracks is! List || tracks.isEmpty) return null;

    final candidates = <Map<String, dynamic>>[];
    for (final entry in tracks) {
      final raw = entry is Map ? entry['track'] : null;
      if (raw is Map) candidates.add(Map<String, dynamic>.from(raw));
    }
    if (candidates.isEmpty) return null;

    candidates.sort((first, second) {
      int score(Map<String, dynamic> item) {
        final titleExact = _normalize(item['track_name']) == _normalize(title);
        final artistExact =
            _normalize(item['artist_name']) == _normalize(artist);
        final itemDuration = (item['track_length'] as num?)?.round();
        final durationClose = duration == null || itemDuration == null
            ? false
            : (itemDuration - duration.inSeconds).abs() <= 4;
        return (titleExact ? 4 : 0) +
            (artistExact ? 3 : 0) +
            (durationClose ? 2 : 0);
      }

      return score(second).compareTo(score(first));
    });
    return candidates.first;
  }

  Future<Map<String, dynamic>?> _request(
    String endpoint,
    Map<String, String> parameters,
  ) async {
    final uri = Uri.parse('$_api/$endpoint')
        .replace(queryParameters: parameters);
    final response = await _client
        .get(uri, headers: const {'User-Agent': 'NovaMusic/1.0'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    dynamic status;
    final message = decoded['message'];
    if (message is Map) {
      final header = message['header'];
      if (header is Map) status = header['status_code'];
    }
    if (status is num && status != 200) return null;
    return decoded;
  }

  static Map? _body(Map<String, dynamic>? response) {
    final message = response?['message'];
    return message is Map ? message['body'] as Map? : null;
  }

  static List<LyricLine> _parseRichSync(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];
      final lines = <LyricLine>[];
      for (final rawLine in decoded) {
        if (rawLine is! Map || rawLine['ts'] is! num || rawLine['l'] is! List) {
          continue;
        }
        final start = (rawLine['ts'] as num).toDouble();
        final end = (rawLine['te'] as num?)?.toDouble();
        final chunks = rawLine['l'] as List;
        final words = <LyricWord>[];
        for (final rawChunk in chunks) {
          if (rawChunk is! Map ||
              rawChunk['c'] is! String ||
              rawChunk['o'] is! num) {
            continue;
          }
          final text = rawChunk['c'] as String;
          final time = start + (rawChunk['o'] as num).toDouble();
          final nextIndex = chunks.indexOf(rawChunk) + 1;
          final nextOffset =
              nextIndex < chunks.length && chunks[nextIndex] is Map
              ? (chunks[nextIndex]['o'] as num?)?.toDouble()
              : null;
          final endTime = nextOffset != null
              ? Duration(milliseconds: ((start + nextOffset) * 1000).round())
              : end == null
              ? null
              : Duration(milliseconds: (end * 1000).round());
          words.add(
            LyricWord(
              time: Duration(milliseconds: (time * 1000).round()),
              text: text,
              endTime: endTime,
            ),
          );
        }
        final text = rawLine['x'] is String
            ? rawLine['x'] as String
            : words.map((word) => word.text).join();
        if (text.isEmpty || words.isEmpty) continue;
        lines.add(
          LyricLine(
            time: Duration(milliseconds: (start * 1000).round()),
            text: text,
            words: words,
          ),
        );
      }
      lines.sort((a, b) => a.time.compareTo(b.time));
      return lines;
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  static String _normalize(Object? value) => (value?.toString() ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}
