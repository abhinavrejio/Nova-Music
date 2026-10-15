import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';
import '../../models/app_settings.dart';

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class AppTheme {
  static ThemeData light(AppSettings settings) {
    final theme = buildLightTheme(settings);

    return settings.animationsEnabled
        ? theme
        : theme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.iOS:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.macOS:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.windows:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.linux:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.fuchsia:
                    _NoAnimationPageTransitionsBuilder(),
              },
            ),
          );
  }

  static ThemeData dark(AppSettings settings) {
    final theme = buildDarkTheme(settings);

    return settings.animationsEnabled
        ? theme
        : theme.copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.iOS:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.macOS:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.windows:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.linux:
                    _NoAnimationPageTransitionsBuilder(),
                TargetPlatform.fuchsia:
                    _NoAnimationPageTransitionsBuilder(),
              },
            ),
          );
  }
}
