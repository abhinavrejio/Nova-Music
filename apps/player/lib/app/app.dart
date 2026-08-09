import 'package:flutter/material.dart';

import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

class NovaMusicApp extends StatelessWidget {
  const NovaMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Nova Music',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}