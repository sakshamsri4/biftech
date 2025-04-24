import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/theme/dimens.dart'; // Added import
import 'package:biftech/shared/widgets/buttons/_base_button.dart'; // Use package import
import 'package:flutter/material.dart';

class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
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
    const height = AppDimens.spaceXXXL; // Was 40.0
    final borderRadius = BorderRadius.circular(AppDimens.radiusM); // Was 8
    const padding =
        EdgeInsets.symmetric(horizontal: AppDimens.spaceS); // Was 12

    // Text Style from Theme
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
              // Use labelMedium
              fontWeight: FontWeight.w500, // Medium weight
              fontSize: 14,
              color: accentPrimary, // Accent color text
            ) ??
        const TextStyle(
          // Fallback style
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: accentPrimary,
        );

    // Adjust text color when disabled
    final currentTextStyle =
        !_isEnabled ? textStyle.copyWith(color: inactive) : textStyle;

    // Build child with optional icon
    Widget buttonChild = Text(label, style: currentTextStyle);
    if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: currentTextStyle.color, size: 18),
          // Smaller icon, use current text color
          const SizedBox(width: 6), // Less spacing
          Text(label, style: currentTextStyle),
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
      useScaleAnimation: false, // Disable scale
      useOpacityAnimation: true, // Enable opacity change on press
      builder: (context, {required bool isPressed}) {
        // Explicitly type isPressed
        // Tertiary button doesn't need a complex builder for background/border,
        // just rely on the BaseButton's opacity handling for enabled/disabled state.
        // We return a simple container for alignment and padding.
        return Container(
          padding: padding,
          alignment: Alignment.center,
          // Show loader or the actual button content
          child: isLoading
              ? const SizedBox(
                  // Use accent color for loader
                  width: 18, // Smaller loader
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentPrimary),
                  ),
                )
              : buttonChild,
        );
      },
      // Pass the child with potentially updated text color
      child: buttonChild,
    );
  }

  // Helper to check if enabled
  bool get _isEnabled => onPressed != null && !isLoading;
}
