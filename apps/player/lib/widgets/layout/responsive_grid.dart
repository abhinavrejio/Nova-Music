import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.itemWidth = 220,
    this.spacing = 20,
  });

  final List<Widget> children;
  final double itemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count =
            (constraints.maxWidth / itemWidth)
                .floor()
                .clamp(1, 8);

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: .72,
          ),
          itemBuilder: (_, index) {
            return children[index];
          },
        );
      },
    );
  }
}