import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../models/app_settings.dart';

/// Shared artwork tint and surface gradient for Now Playing and Lyrics.
class PlayerBackdrop extends StatefulWidget {
  const PlayerBackdrop({
    super.key,
    this.artwork,
    this.motionEnabled = true,
    this.style = BackgroundStyle.gradient,
    this.gradientColor = const Color(0xFFFF6B5F),
    this.gradientEnabled = true,
    this.wallpaperPath,
    this.amoledBlack = false,
  });

  final Uint8List? artwork;
  final bool motionEnabled;
  final BackgroundStyle style;
  final Color gradientColor;
  final bool gradientEnabled;
  final String? wallpaperPath;
  final bool amoledBlack;

  @override
  State<PlayerBackdrop> createState() => _PlayerBackdropState();
}

class _PlayerBackdropState extends State<PlayerBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gradientMotion;

  @override
  void initState() {
    super.initState();
    _gradientMotion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    );
    if (_shouldAnimate) _gradientMotion.repeat();
  }

  @override
  void didUpdateWidget(covariant PlayerBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldAnimate && !_gradientMotion.isAnimating) {
      _gradientMotion.repeat();
    } else if (!_shouldAnimate && _gradientMotion.isAnimating) {
      _gradientMotion.stop();
    }
  }

  bool get _shouldAnimate =>
      widget.motionEnabled &&
      (widget.style == BackgroundStyle.albumArtwork ||
          (widget.style == BackgroundStyle.gradient && widget.gradientEnabled));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _gradientMotion,
      builder: (context, child) {
        final angle = _gradientMotion.value * math.pi * 2;
        if (widget.amoledBlack) {
          return const ColoredBox(color: Colors.black);
        }
        if (widget.style == BackgroundStyle.solidColor) {
          return ColoredBox(color: widget.gradientColor);
        }
        final wallpaper =
            widget.style == BackgroundStyle.wallpaper &&
                !kIsWeb &&
                widget.wallpaperPath != null
            ? File(widget.wallpaperPath!)
            : null;
        final artworkHue = HSLColor.fromColor(widget.gradientColor);
        final secondaryTint = artworkHue
            .withHue((artworkHue.hue + 34) % 360)
            .withSaturation((artworkHue.saturation * .82).clamp(.32, .85))
            .toColor();
        return Stack(
          fit: StackFit.expand,
          children: [
            if (widget.style == BackgroundStyle.albumArtwork &&
                widget.artwork != null)
              Transform.scale(
                scale: 1.08,
                child: Transform.translate(
                  offset: Offset(math.cos(angle) * 22, math.sin(angle) * 22),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
                    child: Opacity(
                      opacity: .52,
                      child: Image.memory(widget.artwork!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            if (wallpaper != null)
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Image.file(
                  wallpaper,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      ColoredBox(color: theme.scaffoldBackgroundColor),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    -1 + math.cos(angle) * .18,
                    -1 + math.sin(angle) * .18,
                  ),
                  end: Alignment(
                    1 - math.cos(angle) * .18,
                    1 - math.sin(angle) * .18,
                  ),
                  colors: [
                    widget.gradientColor.withValues(alpha: .24),
                    secondaryTint.withValues(alpha: .12),
                    theme.scaffoldBackgroundColor.withValues(alpha: .58),
                    theme.scaffoldBackgroundColor.withValues(alpha: .84),
                  ],
                ),
              ),
            ),
            if (widget.style == BackgroundStyle.gradient &&
                widget.gradientEnabled)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.cos(angle) * .7,
                      math.sin(angle) * .7,
                    ),
                    radius: 1.3,
                    colors: [
                      widget.gradientColor.withValues(alpha: .32),
                      secondaryTint.withValues(alpha: .14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _gradientMotion.dispose();
    super.dispose();
  }
}
