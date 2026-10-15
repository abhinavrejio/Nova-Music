import 'package:flutter_test/flutter_test.dart';
import 'package:player/services/lyrics_parser.dart';

void main() {
  test('parses fractional and repeated LRC timestamps in order', () {
    final lines = LyricsParser.parse(
      '[ti:Example]\r\n'
      '[00:02.5][00:04.25]Repeated line\r\n'
      '[00:01.05]Earlier line\r\n'
      '[00:99.00]Invalid seconds',
    );

    expect(lines, hasLength(3));
    expect(lines[0].time, const Duration(milliseconds: 1050));
    expect(lines[0].text, 'Earlier line');
    expect(lines[1].time, const Duration(milliseconds: 2500));
    expect(lines[1].text, 'Repeated line');
    expect(lines[2].time, const Duration(milliseconds: 4250));
  });

  test('ignores metadata and untimed text', () {
    expect(
      LyricsParser.parse('[ar:Artist]\nUntimed lyric\n[00:01]Timed lyric'),
      hasLength(1),
    );
  });

  test('retains genuine inline word timestamps for karaoke highlighting', () {
    final lines = LyricsParser.parse(
      '[00:01.00]<00:01.20>Hello <00:01.65>world!',
    );
    expect(lines, hasLength(1));
    expect(lines.single.text, 'Hello world!');
    expect(lines.single.words.map((word) => word.text), ['Hello ', 'world!']);
    expect(lines.single.words.map((word) => word.time.inMilliseconds), [
      1200,
      1650,
    ]);
  });

  test('line timestamps do not fabricate word timings', () {
    final line = LyricsParser.parse('[00:01.00]Hello world').single;
    expect(line.text, 'Hello world');
    expect(line.words, isEmpty);
  });

  test('parses only word timestamps present in LRCLIB Lyricsfile data', () {
    final lines = LyricsParser.parseLyricsFile('''
version: '1.0'
metadata:
  title: Example
lines:
  - text: 'Hello world!'
    start_ms: 1000
    words:
      - text: 'Hello '
        start_ms: 1200
        end_ms: 1500
      - text: 'world!'
        start_ms: 1650
        end_ms: 1900
  - text: 'Line timed only'
    start_ms: 2200
''');

    expect(lines, hasLength(2));
    expect(lines.first.text, 'Hello world!');
    expect(lines.first.words.map((word) => word.time.inMilliseconds), [
      1200,
      1650,
    ]);
    expect(lines.last.words, isEmpty);
  });

  test('returns no fabricated timings for plain Lyricsfile entries', () {
    final lines = LyricsParser.parseLyricsFile('''
version: '1.0'
lines:
  - text: 'Plain text only'
''');
    expect(lines, isEmpty);
  });
}
