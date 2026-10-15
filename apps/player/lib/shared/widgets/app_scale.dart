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
    final safeScale = scale.isFinite && scale > 0 ? scale : 1.0;

    if ((safeScale - 1.0).abs() < 0.001) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final physicalWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final physicalHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;

        final logicalWidth = physicalWidth / safeScale;
        final logicalHeight = physicalHeight / safeScale;

        final mediaQuery = MediaQuery.of(context);
        final logicalMediaQuery = mediaQuery.copyWith(
          size: Size(logicalWidth, logicalHeight),
          padding: mediaQuery.padding / safeScale,
          viewPadding: mediaQuery.viewPadding / safeScale,
          viewInsets: mediaQuery.viewInsets / safeScale,
          systemGestureInsets:
              mediaQuery.systemGestureInsets / safeScale,
        );

        // Keep the render box constrained to the physical window, while
        // laying out the app in the inverse-scaled logical canvas. A regular
        // SizedBox here inherits the window's tight constraints through
        // Transform and can leave layout and painted geometry out of sync.
        return SizedBox.expand(
          child: Transform.scale(
            scale: safeScale,
            alignment: Alignment.topLeft,
            transformHitTests: true,
            child: OverflowBox(
              alignment: Alignment.topLeft,
              minWidth: logicalWidth,
              maxWidth: logicalWidth,
              minHeight: logicalHeight,
              maxHeight: logicalHeight,
              child: MediaQuery(
                data: logicalMediaQuery,
                child: SizedBox(
                  width: logicalWidth,
                  height: logicalHeight,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
