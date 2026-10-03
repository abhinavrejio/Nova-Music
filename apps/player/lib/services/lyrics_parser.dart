import '../models/lyric_line.dart';

class LyricsParser {
  static List<LyricLine> parse(String syncedLyrics) {
    final result = <LyricLine>[];

    final lines = syncedLyrics.split('\n');

    for (final line in lines) {
      if (!line.startsWith('[')) continue;

      final end = line.indexOf(']');

      if (end == -1) continue;

      final timestamp = line.substring(1, end);

      final text = line.substring(end + 1).trim();

      final parts = timestamp.split(':');

      if (parts.length != 2) continue;

      final minutes = int.tryParse(parts[0]) ?? 0;

      final seconds = double.tryParse(parts[1]) ?? 0;

      result.add(
        LyricLine(
          time: Duration(
            minutes: minutes,
            milliseconds: (seconds * 1000).round(),
          ),
          text: text,
        ),
      );
    }

    return result;
  }
}