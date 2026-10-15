import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/search/search_page.dart';

void main() {
  testWidgets('Search presents a polished library search and empty state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SearchPage())),
    );

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Browse your library'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nothing matches');
    await tester.pump();

    expect(find.text('No matches found'), findsOneWidget);
    expect(find.text('Try another song, artist, album, or playlist.'), findsOneWidget);
  });
}

