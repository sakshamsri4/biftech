import 'dart:math' as math;
import 'package:biftech/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template cred_card}
/// A card with 3D tilt effect and CRED-style design.
/// {@endtemplate}
class CredCard extends StatefulWidget {
  /// {@macro cred_card}
  const CredCard({
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.elevation = 8,
    this.shadowColor,
    this.tiltSensitivity = 0.5,
    this.onTap,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// The width of the card.
  final double? width;

  /// The height of the card.
  final double? height;

  /// The padding around the child.
  final EdgeInsetsGeometry padding;

  /// The border radius of the card.
  final double borderRadius;

  /// The background color of the card.
  final Color? backgroundColor;

  /// The gradient to use for the card background.
  final Gradient? gradient;

  /// The border to use for the card.
  final Border? border;

  /// The elevation of the card.
  final double elevation;

  /// The shadow color of the card.
  final Color? shadowColor;

  /// The sensitivity of the tilt effect (0-1).
  final double tiltSensitivity;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  State<CredCard> createState() => _CredCardState();
}

class _CredCardState extends State<CredCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  Offset _mousePosition = Offset.zero;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  void _onMouseMove(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final offset = box.globalToLocal(event.position);
    
    setState(() {
      _mousePosition = Offset(
        (offset.dx / size.width) * 2 - 1,
        (offset.dy / size.height) * 2 - 1,
      );
    });
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.onTap != null) {
      HapticFeedback.mediumImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = widget.backgroundColor ?? secondaryBackground;
    final defaultShadowColor = widget.shadowColor ?? Colors.black;

    // Calculate rotation based on mouse position
    final double rotateY = _isHovered ? _mousePosition.dx * 5 * widget.tiltSensitivity : 0;
    final double rotateX = _isHovered ? -_mousePosition.dy * 5 * widget.tiltSensitivity : 0;

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      onHover: _onMouseMove,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _scaleAnimation.value,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: widget.height,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(rotateY * (math.pi / 180))
              ..rotateX(rotateX * (math.pi / 180)),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.gradient != null ? null : defaultBackgroundColor,
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.border ??
                  Border.all(
                    color: _isHovered
                        ? accentPrimary.withOpacity(0.5)
                        : const Color(0xFF2A2A2A),
                    width: _isHovered ? 1.5 : 1,
                  ),
              boxShadow: [
                BoxShadow(
                  color: defaultShadowColor.withOpacity(_isHovered ? 0.3 : 0.2),
                  blurRadius: widget.elevation * (_isHovered ? 1.5 : 1),
                  spreadRadius: widget.elevation * 0.2,
                  offset: Offset(0, widget.elevation * 0.5),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: accentPrimary.withOpacity(0.2),
                    blurRadius: widget.elevation * 2,
                    spreadRadius: 0,
                  ),
              ],
            ),
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// {@template cred_glass_card}
/// A card with a glass effect and CRED-style design.
/// {@endtemplate}
class CredGlassCard extends StatelessWidget {
  /// {@macro cred_glass_card}
  const CredGlassCard({
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.opacity = 0.1,
    this.border,
    this.onTap,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// The width of the card.
  final double? width;

  /// The height of the card.
  final double? height;

  /// The padding around the child.
  final EdgeInsetsGeometry padding;

  /// The border radius of the card.
  final double borderRadius;

  /// The opacity of the glass effect (0-1).
  final double opacity;

  /// The border to use for the card.
  final Border? border;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CredCard(
      width: width,
      height: height,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: Colors.white.withOpacity(opacity),
      border: border ??
          Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
      onTap: onTap,
      child: child,
    );
  }
}
