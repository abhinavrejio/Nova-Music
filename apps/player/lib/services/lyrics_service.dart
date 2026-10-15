import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lyric_line.dart';
import '../models/lyrics.dart';
import 'lrclib_service.dart';
import 'lyrics_parser.dart';

class LyricsService {
  LyricsService({LrcLibService? lrclib}) : _lrclib = lrclib ?? LrcLibService();

  LyricsService._() : _lrclib = LrcLibService();

  static final LyricsService instance = LyricsService._();

  final LrcLibService _lrclib;

  Future<Lyrics?> loadLyrics({
    required String title,
    required String artist,
    String? trackId,
    String? album,
    Duration? duration,
    bool refresh = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(trackId, title, artist);

    if (!refresh) {
      final cachedJson = preferences.getString(cacheKey);
      if (cachedJson != null) {
        final cachedLyrics = _decodeCache(cachedJson);
        if (cachedLyrics != null) return cachedLyrics;
      }
    }

    final data = await _lrclib.getLyrics(
      artist: artist,
      title: title,
      album: album,
      duration: duration,
    );
    if (data == null) return null;

    final lyricsFile = data['lyricsfile'] as String?;
    final wordOrLineTimed = lyricsFile == null || lyricsFile.trim().isEmpty
        ? const <LyricLine>[]
        : LyricsParser.parseLyricsFile(lyricsFile);
    final synced = data['syncedLyrics'] as String?;
    final lines = wordOrLineTimed.isNotEmpty
        ? wordOrLineTimed
        : synced == null || synced.trim().isEmpty
        ? const <LyricLine>[]
        : LyricsParser.parse(synced);
    if (lines.isEmpty) return null;

    final lyrics = Lyrics(
      title: title,
      artist: artist,
      synced: true,
      source: 'LRCLIB',
      lines: lines,
    );
    await preferences.setString(cacheKey, jsonEncode(_encodeCache(lyrics)));
    return lyrics;
  }

  static String _cacheKey(String? trackId, String title, String artist) {
    final identity = trackId?.isNotEmpty == true
        ? trackId!
        : '$artist\u0000$title';
    final encoded = base64Url.encode(utf8.encode(identity));
    return 'nova.syncedLyrics.v2.$encoded';
  }

  static Map<String, Object?> _encodeCache(Lyrics lyrics) => {
    'title': lyrics.title,
    'artist': lyrics.artist,
    'source': lyrics.source,
    'lines': [
      for (final line in lyrics.lines)
        {
          'timeMs': line.time.inMilliseconds,
          'text': line.text,
          'words': [
            for (final word in line.words)
              {'timeMs': word.time.inMilliseconds, 'text': word.text},
          ],
        },
    ],
  };

  static Lyrics? _decodeCache(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic> || decoded['lines'] is! List) {
        return null;
      }
      final lines = <LyricLine>[];
      for (final entry in decoded['lines'] as List) {
        if (entry is! Map<String, dynamic> ||
            entry['timeMs'] is! int ||
            entry['text'] is! String) {
          return null;
        }
        final words = <LyricWord>[];
        if (entry['words'] is List) {
          for (final word in entry['words'] as List) {
            if (word is! Map<String, dynamic> ||
                word['timeMs'] is! int ||
                word['text'] is! String) {
              return null;
            }
            words.add(
              LyricWord(
                time: Duration(milliseconds: word['timeMs'] as int),
                text: word['text'] as String,
              ),
            );
          }
        }
        lines.add(
          LyricLine(
            time: Duration(milliseconds: entry['timeMs'] as int),
            text: entry['text'] as String,
            words: words,
          ),
        );
      }
      if (lines.isEmpty) return null;
      return Lyrics(
        title: decoded['title'] as String? ?? '',
        artist: decoded['artist'] as String? ?? '',
        synced: true,
        source: decoded['source'] as String? ?? 'LRCLIB',
        cached: true,
        lines: lines,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
