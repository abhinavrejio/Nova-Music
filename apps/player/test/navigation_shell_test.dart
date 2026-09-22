import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/app/navigation_shell.dart';
import 'package:player/features/home/home_page.dart';
import 'package:player/models/current_song.dart';
import 'package:player/providers/library/library_provider.dart';

class TestLibraryNotifier extends LibraryNotifier {
  @override
  List<CurrentSong> build() => [
        const CurrentSong(
          path: '/music/test.mp3',
          title: 'Test Song',
          artist: 'Test Artist',
          album: 'Test Album',
          duration: Duration(minutes: 3),
        ),
      ];
}

void main() {
  testWidgets('Navigation shell lays out on desktop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryProvider.overrideWith(TestLibraryNotifier.new),
        ],
        child: const MaterialApp(
          home: NavigationShell(child: HomePage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NOVA'), findsOneWidget);
    expect(find.text('Test Song'), findsWidgets);
  });
}
