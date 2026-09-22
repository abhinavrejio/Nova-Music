import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/search/search_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SearchPage filters songs by query', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchPage(),
        ),
      ),
    );

    expect(find.text('Browse your library'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'weeknd');
    await tester.pump();

    expect(find.text('Blinding Lights'), findsOneWidget);
    expect(find.text('Starboy'), findsOneWidget);
  });

  testWidgets('Tapping a song result opens the player screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'blinding');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Blinding Lights'));
    await tester.pumpAndSettle();

    expect(find.text('Now Playing'), findsOneWidget);
  });
}
