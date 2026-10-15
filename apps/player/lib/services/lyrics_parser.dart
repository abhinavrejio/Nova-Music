import '../models/lyric_line.dart';

import 'package:yaml/yaml.dart';

class LyricsParser {
  static final _timestampPattern = RegExp(
    r'\[(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );
  static final _wordTimestampPattern = RegExp(
    r'<(\d{1,3}):(\d{2})(?:[.:](\d{1,3}))?>',
  );

  static List<LyricLine> parse(String syncedLyrics) {
    final result = <LyricLine>[];

    for (final rawLine in syncedLyrics.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      final timestamps = _timestampPattern.allMatches(line).toList();
      if (timestamps.isEmpty || timestamps.first.start != 0) continue;

      final lyricText = line.replaceAll(_timestampPattern, '').trim();
      for (final stamp in timestamps) {
        final lineTime = _parseTimestamp(stamp);
        if (lineTime == null) continue;
        final words = _parseWords(lyricText);
        final text = words.isEmpty
            ? lyricText.replaceAll(_wordTimestampPattern, '').trim()
            : words.map((word) => word.text).join();
        result.add(LyricLine(time: lineTime, text: text, words: words));
      }
    }

    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  /// Parses LRCLIB's Lyricsfile YAML without inferring word positions.
  /// A line is word-synchronized only when the source contains timed words.
  static List<LyricLine> parseLyricsFile(String source) {
    try {
      final document = loadYaml(source);
      if (document is! YamlMap || document['lines'] is! YamlList) {
        return const [];
      }

      final lines = <LyricLine>[];
      for (final rawLine in document['lines'] as YamlList) {
        if (rawLine is! YamlMap) continue;
        final words = <LyricWord>[];
        final rawWords = rawLine['words'];
        if (rawWords is YamlList) {
          final parsedWords = <LyricWord>[];
          var completeWordTiming = rawWords.isNotEmpty;
          for (final rawWord in rawWords) {
            if (rawWord is! YamlMap ||
                rawWord['text'] is! String ||
                rawWord['start_ms'] is! num ||
                (rawWord['start_ms'] as num) < 0) {
              completeWordTiming = false;
              break;
            }
            parsedWords.add(
              LyricWord(
                time: Duration(
                  milliseconds: (rawWord['start_ms'] as num).round(),
                ),
                text: rawWord['text'] as String,
              ),
            );
          }
          if (completeWordTiming && parsedWords.length == rawWords.length) {
            parsedWords.sort((a, b) => a.time.compareTo(b.time));
            words.addAll(parsedWords);
          }
        }

        final text = rawLine['text'] is String
            ? rawLine['text'] as String
            : words.map((word) => word.text).join();
        if (words.isNotEmpty && words.map((word) => word.text).join() != text) {
          // If token text is incomplete, retain the full source line and fall
          // back to line timing rather than hiding or timing invented text.
          words.clear();
        }
        final rawStart = rawLine['start_ms'];
        final startMs = rawStart is num
            ? rawStart.round()
            : words.isNotEmpty
            ? words.first.time.inMilliseconds
            : null;
        if (text.isEmpty || startMs == null) continue;
        lines.add(
          LyricLine(
            time: Duration(milliseconds: startMs),
            text: text,
            words: words,
          ),
        );
      }
      lines.sort((a, b) => a.time.compareTo(b.time));
      return lines;
    } on YamlException {
      return const [];
    }
  }

  static Duration? _parseTimestamp(RegExpMatch stamp) {
    final minutes = int.tryParse(stamp.group(1)!) ?? 0;
    final seconds = int.tryParse(stamp.group(2)!) ?? 0;
    if (seconds > 59) return null;
    final fraction = stamp.group(3) ?? '';
    final milliseconds = fraction.isEmpty
        ? 0
        : int.parse(fraction.padRight(3, '0').substring(0, 3));
    return Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  static List<LyricWord> _parseWords(String text) {
    if (!_wordTimestampPattern.hasMatch(text)) return const [];
    final words = <LyricWord>[];
    var cursor = 0;
    var pendingTime = Duration.zero;
    for (final match in _wordTimestampPattern.allMatches(text)) {
      final segment = text.substring(cursor, match.start);
      if (segment.isNotEmpty) {
        words.add(LyricWord(time: pendingTime, text: segment));
      }
      pendingTime = _parseTimestamp(match) ?? pendingTime;
      cursor = match.end;
    }
    final tail = text.substring(cursor);
    if (tail.isNotEmpty) words.add(LyricWord(time: pendingTime, text: tail));
    return words;
  }
}
