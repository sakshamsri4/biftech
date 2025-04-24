import 'package:biftech/shared/widgets/cards/_base_card.dart';
import 'package:flutter/material.dart';

/// PrimaryCard: A card with a gradient background, prominent shadow,
///  subtle border, and hover effect.
class PrimaryCard extends StatefulWidget {
  const PrimaryCard({
    required this.child,
    this.onTap,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<PrimaryCard> createState() => _PrimaryCardState();
}

class _PrimaryCardState extends State<PrimaryCard> {
  bool _isHovering = false;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    const borderRadiusValue = 16.0;
    final borderRadius = BorderRadius.circular(borderRadiusValue);
    const padding = EdgeInsets.all(20);
    final shadowColor =
        Colors.black.withAlpha((0.3 * 255).round()); // 30% opacity
    final borderColor =
        Colors.white.withAlpha((0.1 * 255).round()); // 10% opacity

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors
          .click, // Indicate it's clickable if onTap is provided
      child: AnimatedScale(
        scale: _isHovering && widget.onTap != null ? 1.02 : 1.0,
        duration: _animationDuration,
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF252525)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8, // Corresponds to elevation
                offset: const Offset(0, 4), // Standard shadow offset
              ),
            ],
          ),
          // Use BaseCard for padding, clipping, and InkWell
          child: BaseCard(
            borderRadius: borderRadius,
            padding: padding,
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
