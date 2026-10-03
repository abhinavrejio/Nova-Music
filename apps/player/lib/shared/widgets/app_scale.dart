import 'package:flutter/material.dart';

class AppScale extends StatelessWidget {
  const AppScale({
    super.key,
    required this.scale,
    required this.child,
  });

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (scale == 1.0) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / scale;
        final height = constraints.maxHeight / scale;

        return ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: Transform.scale(
                alignment: Alignment.topLeft,
                scale: scale,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}