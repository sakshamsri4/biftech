import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.scaleFactor = 0.98,
    this.duration = const Duration(milliseconds: 150),
    super.key,
  });

  final Widget child;
  final double scaleFactor;
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Using a spring simulation for the bounce back effect
  final SpringDescription _spring =
      const SpringDescription(mass: 1, stiffness: 150, damping: 15);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 1, end: widget.scaleFactor)
        .animate(_controller); // Will be driven by simulation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    // Animate towards the pressed scale
    _controller.animateTo(1, curve: Curves.easeOut);
  }

  void _handleTapUp(TapUpDetails details) {
    // Use spring simulation to animate back to original scale
    final simulation = SpringSimulation(_spring, _controller.value, 0, 0);
    _controller.animateWith(simulation);
  }

  void _handleTapCancel() {
    // Use spring simulation to animate back if cancelled
    final simulation = SpringSimulation(_spring, _controller.value, 0, 0);
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
