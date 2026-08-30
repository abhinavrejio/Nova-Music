import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_kit/media_kit.dart';

import 'app/app.dart';

void main() {
  // Initialize MediaKit
  MediaKit.ensureInitialized();

  runApp(
    const ProviderScope(
      child: NovaMusicApp(),
    ),
  );
}