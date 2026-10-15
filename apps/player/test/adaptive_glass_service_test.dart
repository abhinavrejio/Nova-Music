import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/models/app_settings.dart';
import 'package:player/services/adaptive_glass_service.dart';

void main() {
  test('recommends conservative glass quality for constrained devices', () {
    final scan = AdaptiveGlassService.scan(
      logicalProcessors: 2,
      physicalSize: const Size(1920, 1080),
    );
    expect(scan.quality, GlassQuality.low);
  });

  test('recommends richer glass when available capacity is higher', () {
    final scan = AdaptiveGlassService.scan(
      logicalProcessors: 8,
      physicalSize: const Size(1920, 1080),
    );
    expect(scan.quality, GlassQuality.high);
  });

  test('uses measured raster frame p95 for a bounded glass recommendation', () {
    final constrained = AdaptiveGlassService.fromRasterTimings(
      logicalProcessors: 8,
      physicalSize: const Size(1920, 1080),
      rasterDurations: [
        const Duration(milliseconds: 11),
        const Duration(milliseconds: 14),
        const Duration(milliseconds: 35),
      ],
    );
    expect(constrained.quality, GlassQuality.low);
    expect(constrained.rasterP95Milliseconds, 35);
  });

  test('falls back to supported signals when the frame sample is empty', () {
    final scan = AdaptiveGlassService.fromRasterTimings(
      logicalProcessors: 8,
      physicalSize: const Size(1920, 1080),
      rasterDurations: const [],
    );
    expect(scan.quality, GlassQuality.high);
    expect(scan.rasterP95Milliseconds, isNull);
  });
}
