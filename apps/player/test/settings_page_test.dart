import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/settings/settings_page.dart';
import 'package:player/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Glass quality remains manually selectable with Adaptive Glass enabled',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsPage())),
      );

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      final qualityPicker = tester
          .widget<DropdownButtonFormField<GlassQuality>>(
            find.byType(DropdownButtonFormField<GlassQuality>),
          );
      expect(qualityPicker.onChanged, isNotNull);
      expect(find.text('BACKGROUND STYLE'), findsOneWidget);
      expect(find.text('AMOLED Black'), findsOneWidget);
    },
  );

  testWidgets('Playback settings do not expose keyboard shortcuts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );
    await tester.tap(find.text('Playback & Audio'));
    await tester.pumpAndSettle();
    expect(find.text('KEYBOARD SHORTCUTS'), findsNothing);
    expect(find.text('Play / pause'), findsNothing);
  });
}
