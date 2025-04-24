import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GridLayout<T> extends StatelessWidget {
  const GridLayout({
    required this.items,
    required this.itemBuilder,
    this.mobileCrossAxisCount = 1, // Default to single column on mobile
    this.largeScreenCrossAxisCount =
        2, // Default to 2 columns on larger screens
    this.crossAxisSpacing = 16.0, // Gutters
    this.mainAxisSpacing = 16.0, // Gutters
    this.childAspectRatio = 1.0,
    this.largeScreenBreakpoint = 600.0, // Breakpoint for larger screens
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    super.key,
  });
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final int mobileCrossAxisCount;
  final int largeScreenCrossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final double largeScreenBreakpoint;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= largeScreenBreakpoint
            ? largeScreenCrossAxisCount
            : mobileCrossAxisCount;

        return AnimationLimiter(
          child: GridView.builder(
            itemCount: items.length,
            padding: padding ?? const EdgeInsets.all(16),
            physics: physics ?? const AlwaysScrollableScrollPhysics(),
            shrinkWrap: shrinkWrap,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: crossAxisCount,
                child: ScaleAnimation(
                  // Example animation
                  child: FadeInAnimation(
                    child: itemBuilder(context, index, item),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
