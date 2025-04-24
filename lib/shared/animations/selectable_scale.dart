import 'package:flutter/material.dart';

class SelectableScale extends StatefulWidget {
  const SelectableScale({
    required this.child,
    required this.isSelected,
    this.scaleFactor = 1.03,
    this.duration =
        const Duration(milliseconds: 200), // Slightly longer for selection
    this.curve = Curves.easeOutBack, // Curve with overshoot
    super.key,
  });

  final Widget child;
  final bool isSelected;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;

  @override
  State<SelectableScale> createState() => _SelectableScaleState();
}

class _SelectableScaleState extends State<SelectableScale> {
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.isSelected ? widget.scaleFactor : 1.0,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );
  }
}
