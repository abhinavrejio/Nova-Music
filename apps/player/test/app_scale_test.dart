import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/shared/widgets/app_scale.dart';

void main() {
  testWidgets('scales the logical canvas and keeps transformed hit testing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final scale in [0.9, 0.95, 1.0, 1.05, 1.2]) {
      var tapped = false;
      Size? childSize;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppScale(
              scale: scale,
              child: Builder(
                builder: (context) => LayoutBuilder(
                  builder: (context, constraints) {
                    childSize = constraints.biggest;
                    return GestureDetector(
                      key: const ValueKey('scaled-surface'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => tapped = true,
                      child: const ColoredBox(color: Colors.blue),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(childSize!.width, closeTo(800 / scale, 0.1));
      expect(childSize!.height, closeTo(600 / scale, 0.1));

      await tester.tapAt(Offset(400 * scale, 300 * scale));
      await tester.pump();
      expect(tapped, isTrue, reason: 'Hit testing failed at scale $scale');
    }
  });

  testWidgets('scroll extent follows window resizing at reduced scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget buildScaledWindow() => MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: AppScale(
          scale: 0.9,
          child: SingleChildScrollView(
            child: SizedBox(height: 1400, width: double.infinity),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildScaledWindow());
    final scrollable = find.byType(Scrollable);
    final initialExtent = tester
        .state<ScrollableState>(scrollable)
        .position
        .maxScrollExtent;
    expect(initialExtent, closeTo(1400 - 600 / 0.9, 0.1));

    await tester.drag(scrollable, const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      greaterThan(0),
    );

    await tester.binding.setSurfaceSize(const Size(1000, 700));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1000, 700)),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: AppScale(
            scale: 0.9,
            child: SingleChildScrollView(
              child: SizedBox(height: 1400, width: double.infinity),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final resizedExtent = tester
        .state<ScrollableState>(scrollable)
        .position
        .maxScrollExtent;
    expect(resizedExtent, closeTo(1400 - 700 / 0.9, 0.1));
    expect(resizedExtent, lessThan(initialExtent));
  });
}
