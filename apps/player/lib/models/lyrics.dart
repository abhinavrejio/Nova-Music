import 'lyric_line.dart';

class Lyrics {
  const Lyrics({
    required this.title,
    required this.artist,
    required this.lines,
    this.synced = false,
    this.source = '',
    this.cached = false,
  });

  final String title;
  final String artist;
  final List<LyricLine> lines;

  final bool synced;
  final String source;
  final bool cached;

  bool get hasWordSync => lines.any((line) => line.words.isNotEmpty);
}
