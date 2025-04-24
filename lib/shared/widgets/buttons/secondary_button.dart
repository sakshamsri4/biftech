import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/widgets/buttons/_base_button.dart'; // Use package import
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
    const padding = EdgeInsets.symmetric(horizontal: 24);
    const borderColor = accentPrimary; // Use primary accent for border

    // Text Style from Theme
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500, // Medium weight
              fontSize: 16,
              color: accentPrimary, // Text color matches border
            ) ??
        const TextStyle(
          // Fallback style
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: accentPrimary,
        );

    // Build child with optional icon
    Widget buttonChild = Text(label, style: textStyle);
    if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentPrimary, size: 20),
          const SizedBox(width: 8),
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
        // Explicitly type isPressed
        // Adjust border color when pressed or disabled
        final currentBorderColor = !_isEnabled
            ? inactive // Disabled border color
            : isPressed
                ? accentSecondary // Pressed border color
                : borderColor; // Default border color

        // Adjust text color when disabled
        final currentTextStyle =
            !_isEnabled ? textStyle.copyWith(color: inactive) : textStyle;

        // Rebuild child with potentially updated text style for disabled state
        Widget currentButtonChild = Text(label, style: currentTextStyle);
        if (icon != null) {
          currentButtonChild = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: currentTextStyle.color,
                size: 20,
              ), // Use text color for icon
              const SizedBox(width: 8),
              Text(label, style: currentTextStyle),
            ],
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Explicitly transparent
            borderRadius: borderRadius,
            border: Border.all(
              color: currentBorderColor,
            ),
          ),
          padding: padding,
          alignment: Alignment.center,
          // Use the potentially updated child for disabled state
          child: isLoading
              ? const SizedBox(
                  // Use accent color for loader
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(accentPrimary),
                  ),
                )
              : currentButtonChild,
        );
      },
      // Pass original child to base, builder handles disabled/loading state visuals
      child: buttonChild,
    );
  }

  // Helper to check if enabled
  bool get _isEnabled => onPressed != null && !isLoading;
}
