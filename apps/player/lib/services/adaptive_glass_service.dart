import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class AdaptiveGlassScan {
  const AdaptiveGlassScan({
    required this.quality,
    required this.logicalProcessors,
    required this.pixelCount,
    this.rasterP95Milliseconds,
  });

  final GlassQuality quality;
  final int logicalProcessors;
  final int pixelCount;
  final double? rasterP95Milliseconds;

  String get description {
    final raster = rasterP95Milliseconds;
    final workload =
        '$logicalProcessors logical processors · ${(pixelCount / 1000000).toStringAsFixed(1)} MP window';
    return raster == null
        ? workload
        : '${raster.toStringAsFixed(1)} ms raster-frame p95 · $workload';
  }
}

/// Uses Flutter-exposed workload signals; the engine does not expose GPU model,
/// memory, or utilization to Dart on Windows.
class AdaptiveGlassService {
  static AdaptiveGlassScan scan({
    required int logicalProcessors,
    required Size physicalSize,
  }) {
    final pixels = (physicalSize.width * physicalSize.height).round();
    final quality = logicalProcessors <= 2 || pixels > 8000000
        ? GlassQuality.low
        : logicalProcessors <= 4 || pixels > 5000000
        ? GlassQuality.balanced
        : GlassQuality.high;
    return AdaptiveGlassScan(
      quality: quality,
      logicalProcessors: logicalProcessors,
      pixelCount: pixels,
    );
  }

  /// Combines a short in-app raster frame sample with Flutter-exposed device
  /// and display signals. It does not claim to identify or benchmark a GPU.
  static AdaptiveGlassScan fromRasterTimings({
    required int logicalProcessors,
    required Size physicalSize,
    required List<Duration> rasterDurations,
  }) {
    final pixels = (physicalSize.width * physicalSize.height).round();
    if (rasterDurations.isEmpty) {
      return scan(
        logicalProcessors: logicalProcessors,
        physicalSize: physicalSize,
      );
    }
    final ordered =
        rasterDurations
            .map((duration) => duration.inMicroseconds / 1000)
            .toList()
          ..sort();
    final p95Index = ((ordered.length - 1) * .95).ceil();
    final p95 = ordered[p95Index];
    final quality = p95 >= 30 || logicalProcessors <= 2 || pixels > 8000000
        ? GlassQuality.low
        : p95 >= 20 || logicalProcessors <= 4 || pixels > 5000000
        ? GlassQuality.balanced
        : GlassQuality.high;
    return AdaptiveGlassScan(
      quality: quality,
      logicalProcessors: logicalProcessors,
      pixelCount: pixels,
      rasterP95Milliseconds: p95,
    );
  }
}
