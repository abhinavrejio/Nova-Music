import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/settings/settings_page.dart';
import 'package:player/models/app_settings.dart';

void main() {
  testWidgets('SettingsPage exposes playback and appearance preferences', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Liquid Glass'), findsOneWidget);
    expect(find.text('Auto Play'), findsOneWidget);
  });

  testWidgets('SettingsPage toggles the shared shuffle mode', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    final shuffleSwitch = find.byType(Switch).at(2);
    expect(tester.widget<Switch>(shuffleSwitch).value, isFalse);

    await tester.tap(shuffleSwitch);
    await tester.pump();

    expect(find.text('Shuffle'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch).at(2)).value, isTrue);
  });

  testWidgets('SettingsPage cycles the shared repeat mode', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    expect(find.text('OFF'), findsOneWidget);

    await tester.tap(find.text('Repeat'));
    await tester.pump();

    expect(find.text('ALL'), findsOneWidget);
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
