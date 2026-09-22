import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_kit/media_kit.dart';

import 'app/app.dart';

void main() {
  try {
    MediaKit.ensureInitialized();
  } catch (_) {
    // Keep the UI available when native audio libraries are unavailable.
  }

  runApp(
    const ProviderScope(
      child: NovaMusicApp(),
    ),
  );
}