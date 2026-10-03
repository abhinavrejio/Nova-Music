import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:player/features/settings/settings_page.dart';
import 'package:player/models/app_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('SettingsPage opens playback and appearance settings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );

    expect(find.text('Playback'), findsOneWidget);
    expect(find.text('Appearance'), findsNWidgets(2));
    expect(find.text('Theme'), findsNothing);
    await tester.tap(find.text('Playback'));
    await tester.pumpAndSettle();
    expect(find.text('Auto Play'), findsOneWidget);
    expect(find.text('Shuffle'), findsOneWidget);
  });

  testWidgets('Search, Player, and Sidebar menus have distinct controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Show song results'), findsOneWidget);
    expect(find.text('Show playlist results'), findsOneWidget);

    await tester.tap(find.text('Player'));
    await tester.pumpAndSettle();
    expect(find.text('Show shuffle control'), findsOneWidget);
    expect(find.text('Show queue button'), findsOneWidget);

    await tester.tap(find.text('Sidebar'));
    await tester.pumpAndSettle();
    expect(find.text('Compact navigation'), findsOneWidget);
    expect(find.text('Show sidebar tagline'), findsOneWidget);
  });

  testWidgets('Playback settings toggle the shared shuffle mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );

    await tester.tap(find.text('Playback'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shuffle'));
    await tester.pump();

    final shuffleSwitch = find.descendant(
      of: find.ancestor(
        of: find.text('Shuffle'),
        matching: find.byType(SwitchListTile),
      ),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(shuffleSwitch).value, isTrue);
  });

  testWidgets('Playback settings cycle the shared repeat mode', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );

    await tester.tap(find.text('Playback'));
    await tester.pumpAndSettle();
    expect(find.text('Off'), findsOneWidget);

    await tester.tap(find.text('Off'));
    await tester.pump();

    expect(find.text('All songs'), findsOneWidget);
  });

  test('App settings clamps UI scale to the slider range', () {
    const settings = AppSettings(
      themeMode: ThemeMode.system,
      liquidGlass: true,
      uiScale: 0.0,
      hardwareAcceleration: true,
    );

    expect(settings.copyWith(uiScale: 0.0).uiScale, 0.9);
  });
}
