import 'dart:math' as math;

import 'package:flutter/material.dart';

class NovaEqualizer extends StatefulWidget {
  const NovaEqualizer({super.key, required this.isPlaying});

  final bool isPlaying;

  @override
  State<NovaEqualizer> createState() => _NovaEqualizerState();
}

class _NovaEqualizerState extends State<NovaEqualizer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant NovaEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return SizedBox(
      width: 76,
      height: 28,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final wave = math.sin(_controller.value * math.pi * 2 + index * 0.8).abs();
            final height = 6 + wave * 18;
            return Container(
              width: 5,
              height: widget.isPlaying ? height : 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.45 + wave * 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ),
    );
  }
}
