import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/lyrics/widgets/lyrics_scroll_view.dart';
import 'package:player/models/lyric_line.dart';

void main() {
  testWidgets('highlights the timestamped word at the current position', (
    tester,
  ) async {
    const line = LyricLine(
      time: Duration(seconds: 1),
      text: 'Hello world!',
      words: [
        LyricWord(time: Duration(milliseconds: 1100), text: 'Hello '),
        LyricWord(time: Duration(milliseconds: 1500), text: 'world!'),
      ],
    );

    Future<void> pumpAt(Duration position) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 480,
              height: 300,
              child: LyricsScrollView(
                lines: const [line],
                position: position,
                onSeek: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpAt(const Duration(milliseconds: 1300));
    final lyricText = find.byKey(const ValueKey('karaoke-lyric-text'));
    var lyricWidget = tester.widget<Text>(lyricText);
    var words = (lyricWidget.textSpan! as TextSpan).children!.cast<TextSpan>();
    final primary = Theme.of(tester.element(lyricText)).colorScheme.primary;
    expect(words[0].style?.color, primary);
    expect(words[1].style?.color, isNot(primary));

    await pumpAt(const Duration(milliseconds: 1700));
    lyricWidget = tester.widget<Text>(lyricText);
    words = (lyricWidget.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(words[1].style?.color, primary);
  });
}
