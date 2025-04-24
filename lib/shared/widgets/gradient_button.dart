import 'package:biftech/shared/animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.onPressed,
    required this.child,
    this.gradient = const LinearGradient(
      colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      // Add press animation
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact(); // Add haptic feedback
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // Remove default padding
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 5, // Add some elevation
          shadowColor: Colors.black.withAlpha(102), // 0.4 opacity
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withAlpha((0.4 * 255).round()), // Use withAlpha
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            padding: padding,
            alignment: Alignment.center,
            child: DefaultTextStyle(
              // Ensure text style is appropriate
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ) ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
