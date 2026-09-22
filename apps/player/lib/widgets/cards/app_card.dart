import 'package:flutter/material.dart';

import '../../design/colors.dart';
import '../../design/radii.dart';
import '../../design/shadows.dart';
import '../../design/animations.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.alignment,
    this.enableHover = true,
  });

  final Widget child;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;

  final EdgeInsetsGeometry margin;

  final double? width;

  final double? height;

  final Color? backgroundColor;

  final Border? border;

  final BorderRadius? borderRadius;

  final AlignmentGeometry? alignment;

  final bool enableHover;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadii.lg);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) {
        if (widget.enableHover) {
          setState(() => hovering = true);
        }
      },
      onExit: (_) {
        if (widget.enableHover) {
          setState(() => hovering = false);
        }
      },
      child: AnimatedContainer(
        duration: AppAnimations.medium,
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()
  ..translateByDouble(
    0.0,
    hovering ? -4.0 : 0.0,
    0.0,
    1.0,
  ),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.card,
          borderRadius: radius,
          border: widget.border,
          boxShadow: hovering
              ? AppShadows.large
              : AppShadows.medium,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            child: Container(
              alignment: widget.alignment,
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}