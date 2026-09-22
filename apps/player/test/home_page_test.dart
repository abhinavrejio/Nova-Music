import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/home/home_page.dart';
import 'package:player/models/current_song.dart';
import 'package:player/providers/library/library_provider.dart';

class TestLibraryNotifier extends LibraryNotifier {
  @override
  List<CurrentSong> build() => [
        const CurrentSong(
          path: '/music/blinding-lights.mp3',
          title: 'Blinding Lights',
          artist: 'The Weeknd',
          album: 'After Hours',
          duration: Duration(minutes: 3),
        ),
      ];
}

void main() {
  testWidgets('Home page taps a quick pick and opens the player', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryProvider.overrideWith(TestLibraryNotifier.new),
        ],
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.tap(find.text('Blinding Lights').first);
    await tester.pumpAndSettle();

    expect(find.text('Now Playing'), findsOneWidget);
  });
}
