import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/buttons/_base_button.dart'; // Use package import
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    const height = 48.0;
    final borderRadius = BorderRadius.circular(12);
    const padding = EdgeInsets.symmetric(horizontal: 24); // Adjust as needed

    // Gradient definition
    const gradient = LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF5A52CC)],
    );

    // Text Style from Theme
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold, // Explicitly bold
              fontSize: 16,
              color: textWhite, // Ensure text is white
            ) ??
        const TextStyle(
          // Fallback style
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textWhite,
        );

    // Build child with optional icon
    Widget buttonChild = Text(label, style: textStyle);
    if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textWhite, size: 20), // Icon style
          const SizedBox(width: 8), // Consistent spacing
          Text(label, style: textStyle),
        ],
      );
    }

    return BaseButton(
      // Changed from _BaseButton
      onPressed: onPressed,
      isLoading: isLoading,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      builder: (context, bool isPressed) {
        return Ink(
          decoration: BoxDecoration(
            gradient: _isEnabled ? gradient : null, // No gradient when disabled
            color: _isEnabled
                ? null
                : inactive, // Use inactive color when disabled
            borderRadius: borderRadius,
            boxShadow: !_isEnabled || isPressed
                ? null // No shadow when disabled or pressed
                : [
                    BoxShadow(
                      color: accentPrimary.withAlpha((0.3 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            padding: padding,
            alignment: Alignment.center,
            child: buttonChild,
          ),
        );
      },
      child: buttonChild, // Pass the child content to BaseButton
    );
  }

  // Helper to check if enabled (used for shadow/gradient/color)
  bool get _isEnabled => onPressed != null && !isLoading;
}
