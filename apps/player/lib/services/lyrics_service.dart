import '../models/lyric_line.dart';
import '../models/lyrics.dart';

import 'lrclib_service.dart';
import 'lyrics_parser.dart';

class LyricsService {
  LyricsService._();

  static final LyricsService instance = LyricsService._();

  final LrcLibService _lrclib = LrcLibService();

  Future<Lyrics?> loadLyrics({
    required String title,
    required String artist,
  }) async {
    final data = await _lrclib.getLyrics(
      artist: artist,
      title: title,
    );

    if (data == null) return null;

    final synced = data['syncedLyrics'] as String?;

    final plain = data['plainLyrics'] as String?;

    final lines = synced != null
        ? LyricsParser.parse(synced)
        : (plain ?? '')
            .split('\n')
            .map(
              (e) => LyricLine(
                time: Duration.zero,
                text: e,
              ),
            )
            .toList();

    return Lyrics(
      title: title,
      artist: artist,
      synced: synced != null,
      source: 'LRCLIB',
      lines: lines,
    );
  }
}