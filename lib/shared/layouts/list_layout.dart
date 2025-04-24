import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ListLayout<T> extends StatefulWidget {
  const ListLayout({
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.itemSpacing = 8.0, // Spacing between items
    super.key,
  });
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final double itemSpacing;

  @override
  State<ListLayout<T>> createState() => _ListLayoutState<T>();
}

class _ListLayoutState<T> extends State<ListLayout<T>> {
  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.separated(
        itemCount: widget.items.length,
        padding: widget.padding ?? const EdgeInsets.all(16),
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        shrinkWrap: widget.shrinkWrap,
        scrollDirection: widget.scrollDirection,
        separatorBuilder: (context, index) => SizedBox(
          height:
              widget.scrollDirection == Axis.vertical ? widget.itemSpacing : 0,
          width: widget.scrollDirection == Axis.horizontal
              ? widget.itemSpacing
              : 0,
        ),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              // Example animation
              verticalOffset:
                  widget.scrollDirection == Axis.vertical ? 50.0 : 0.0,
              horizontalOffset:
                  widget.scrollDirection == Axis.horizontal ? 50.0 : 0.0,
              child: FadeInAnimation(
                child: widget.itemBuilder(context, index, item),
              ),
            ),
          );
        },
      ),
    );
  }
}
