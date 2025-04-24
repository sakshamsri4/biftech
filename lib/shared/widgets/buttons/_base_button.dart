import 'package:biftech/shared/theme/colors.dart'; // Assuming colors are defined here
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

// Base class for handling common button logic
//(loading, disabled, haptics, animation)
class BaseButton extends StatefulWidget {
  // Renamed from _BaseButton
  const BaseButton({
    // Renamed constructor
    required this.child,
    required this.onPressed,
    required this.isLoading,
    required this.height,
    required this.borderRadius,
    required this.padding,
    required this.builder,
    this.iconSpacing = 8.0,
    this.useScaleAnimation = true,
    this.useOpacityAnimation = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double iconSpacing;
  final bool useScaleAnimation;
  final bool useOpacityAnimation;

  // Builder function to construct the specific button appearance
  final Widget Function(BuildContext context, {required bool isPressed})
      builder;

  @override
  State<BaseButton> createState() => BaseButtonState(); // Renamed state class
}

class BaseButtonState extends State<BaseButton> // Renamed from _BaseButtonState
    with
        SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Quick animation
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 1, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      _animationController.forward();
      HapticFeedback.lightImpact(); // Standard light haptic
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onPressed!(); // Execute the callback
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.isLoading
        ? const SizedBox(
            width: 20, // Consistent size for indicator
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
                  AlwaysStoppedAnimation<Color>(textWhite), // Use theme color
            ),
          )
        : widget.child;

    Widget buttonContent = Center(child: content);

    // Apply animations based on flags
    if (widget.useScaleAnimation) {
      buttonContent = ScaleTransition(
        scale: _scaleAnimation,
        child: buttonContent,
      );
    }
    if (widget.useOpacityAnimation) {
      buttonContent = FadeTransition(
        opacity: _opacityAnimation,
        child: buttonContent,
      );
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Opacity(
        opacity: _isEnabled ? 1.0 : 0.5, // Dim button when disabled
        child: SizedBox(
          height: widget.height,
          child: widget.builder(
            context,
            isPressed: _isPressed,
          ), // Use builder for appearance
        ),
      ),
    );
  }
}
