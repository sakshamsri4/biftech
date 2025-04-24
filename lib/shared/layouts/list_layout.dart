import 'package:biftech/shared/animations/animations.dart'; // Import animations
import 'package:flutter/material.dart';

class ListLayout<T> extends StatefulWidget {
  const ListLayout({
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.itemSpacing = 8.0, // Spacing between items
    this.staggerDelay = const Duration(milliseconds: 50), // Stagger delay
    super.key,
  });
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final double itemSpacing;
  final Duration staggerDelay; // Added stagger delay

  @override
  State<ListLayout<T>> createState() => _ListLayoutState<T>();
}

class _ListLayoutState<T> extends State<ListLayout<T>> {
  @override
  Widget build(BuildContext context) {
    // Using ListView.builder directly for custom staggering
    return ListView.separated(
      itemCount: widget.items.length,
      padding: widget.padding ?? const EdgeInsets.all(16),
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      separatorBuilder: (context, index) => SizedBox(
        height:
            widget.scrollDirection == Axis.vertical ? widget.itemSpacing : 0,
        width:
            widget.scrollDirection == Axis.horizontal ? widget.itemSpacing : 0,
      ),
      itemBuilder: (context, index) {
        final item = widget.items[index];
        // Apply EntranceAnimation with calculated delay
        return EntranceAnimation(
          delay: widget.staggerDelay * index,
          child: widget.itemBuilder(context, index, item),
        );
      },
    );
  }
}
