import 'package:flutter/material.dart';

/// Base widget for cards, handling common properties like padding,
///  radius, and child.
/// Specific styling (background, border, shadow) is applied by
/// subclasses.
class BaseCard extends StatelessWidget {
  const BaseCard({
    required this.child,
    required this.padding,
    required this.borderRadius,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // The actual decoration (color, gradient, border, shadow)
    // will be provided by the specific card implementations wrapping this.
    // This base focuses on the core structure: padding and clipping.
    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        type: MaterialType.transparency, // Ensure InkWell splashes are clipped
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius, // Match splash radius to card radius
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
