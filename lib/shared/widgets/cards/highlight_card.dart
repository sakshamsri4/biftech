import 'package:biftech/shared/widgets/cards/_base_card.dart';
import 'package:flutter/material.dart';

/// HighlightCard: A card featuring a gradient border and a glowing shadow.
class HighlightCard extends StatelessWidget {
  const HighlightCard({
    required this.child,
    this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const borderRadiusValue = 16.0;
    final borderRadius = BorderRadius.circular(borderRadiusValue);
    const padding = EdgeInsets.all(20);
    const backgroundColor = Color(0xFF1A1A1A); // Slightly darker background
    const gradientBorderWidth = 2.0;
    final glowColor =
        Colors.purple.withAlpha((0.4 * 255).round()); // Purple glow

    return Container(
      padding: const EdgeInsets.all(
        gradientBorderWidth,
      ), // Padding acts as border thickness
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.blue], // Purple to Blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 12, // Larger blur for glow effect
            spreadRadius: 2, // Spread the glow slightly
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            borderRadiusValue - gradientBorderWidth,
          ), // Inner radius
        ),
        // Use BaseCard for padding, clipping, and InkWell
        child: BaseCard(
          // Adjust radius for BaseCard to account
          // for the outer border container
          borderRadius: BorderRadius.circular(
            borderRadiusValue - gradientBorderWidth,
          ),
          padding: padding,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
