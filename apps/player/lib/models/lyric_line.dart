class LyricLine {
  const LyricLine({
    required this.time,
    required this.text,
    this.words = const [],
  });

  final Duration time;
  final String text;

  /// Word start times are present only when the source provides inline timing.
  final List<LyricWord> words;
}

class LyricWord {
  const LyricWord({required this.time, required this.text});

  final Duration time;
  final String text;
}
