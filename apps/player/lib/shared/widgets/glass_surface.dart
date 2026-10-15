import 'dart:ui';

import 'package:flutter/material.dart';

/// A shared translucent, softly blurred surface for Nova's floating UI.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.color,
    this.border,
    this.blur = 18,
    this.borderOpacity = .15,
    this.surfaceOpacity = .58,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Border? border;
  final double blur;
  final double borderOpacity;
  final double surfaceOpacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = color ?? theme.colorScheme.surface;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: .10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: base.withValues(alpha: surfaceOpacity.clamp(0.0, 1.0)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: .09),
                  base.withValues(alpha: surfaceOpacity * .72),
                  base.withValues(alpha: surfaceOpacity),
                ],
              ),
              borderRadius: borderRadius,
              border:
                  border ??
                  Border.all(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: borderOpacity,
                    ),
                  ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
