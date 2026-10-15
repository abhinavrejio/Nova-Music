import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'current_song_provider.dart';

final albumArtworkColorProvider = FutureProvider.family<Color, String>((
  ref,
  path,
) async {
  final song = ref.watch(currentSongProvider);
  final bytes = song?.path == path ? song?.artwork : null;
  if (bytes == null || bytes.isEmpty) return const Color(0xFFFF6B5F);

  ui.Codec? codec;
  ui.Image? image;
  try {
    codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 32,
      targetHeight: 32,
    );
    final frame = await codec.getNextFrame();
    image = frame.image;
    final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (pixels == null) return const Color(0xFFFF6B5F);

    final bins = <int, (int red, int green, int blue, int count)>{};
    for (var offset = 0; offset < pixels.lengthInBytes; offset += 4) {
      final alpha = pixels.getUint8(offset + 3);
      if (alpha < 160) continue;
      final red = pixels.getUint8(offset);
      final green = pixels.getUint8(offset + 1);
      final blue = pixels.getUint8(offset + 2);
      final key = ((red >> 5) << 10) | ((green >> 5) << 5) | (blue >> 5);
      final previous = bins[key] ?? (0, 0, 0, 0);
      bins[key] = (
        previous.$1 + red,
        previous.$2 + green,
        previous.$3 + blue,
        previous.$4 + 1,
      );
    }
    if (bins.isEmpty) return const Color(0xFFFF6B5F);
    final dominant = bins.values.reduce((a, b) => a.$4 >= b.$4 ? a : b);
    final base = Color.fromARGB(
      255,
      dominant.$1 ~/ dominant.$4,
      dominant.$2 ~/ dominant.$4,
      dominant.$3 ~/ dominant.$4,
    );
    final hsl = HSLColor.fromColor(base);
    return hsl
        .withSaturation(hsl.saturation.clamp(.38, .88).toDouble())
        .withLightness(hsl.lightness.clamp(.34, .68).toDouble())
        .toColor();
  } catch (_) {
    return const Color(0xFFFF6B5F);
  } finally {
    image?.dispose();
    codec?.dispose();
  }
});
