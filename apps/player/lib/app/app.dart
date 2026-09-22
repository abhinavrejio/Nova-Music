import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../providers/startup_provider.dart';
import 'config/router/app_router.dart';
import 'theme/app_theme.dart';

class NovaMusicApp extends ConsumerStatefulWidget {
  const NovaMusicApp({super.key});

  @override
  ConsumerState<NovaMusicApp> createState() => _NovaMusicAppState();
}

class _NovaMusicAppState extends ConsumerState<NovaMusicApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(startupProvider));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nova Music',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
    );
  }
}