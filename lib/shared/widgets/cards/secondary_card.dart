import 'package:flutter/material.dart';
import 'package:biftech/shared/widgets/cards/_base_card.dart';

/// SecondaryCard: A simpler card with a solid background and less elevation.
class SecondaryCard extends StatelessWidget {
  const SecondaryCard({
    required this.child,
    this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const borderRadiusValue = 12.0;
    final borderRadius = BorderRadius.circular(borderRadiusValue);
    const padding = EdgeInsets.all(16);
    const backgroundColor = Color(0xFF1E1E1E);
    final shadowColor =
        Colors.black.withAlpha((0.2 * 255).round()); // Subtle shadow

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4, // Corresponds to elevation
            offset: const Offset(0, 2), // Smaller offset for less elevation
          ),
        ],
      ),
      // Use BaseCard for padding, clipping, and InkWell
      child: BaseCard(
        borderRadius: borderRadius,
        padding: padding,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
