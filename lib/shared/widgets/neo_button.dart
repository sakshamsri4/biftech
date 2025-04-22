import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';

/// {@template neo_button}
/// A custom button with NeoPop styling.
/// {@endtemplate}
class NeoButton extends StatelessWidget {
  /// {@macro neo_button}
  const NeoButton({
    required this.onTap,
    required this.label,
    this.isLoading = false,
    this.isEnabled = true,
    super.key,
  });

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// The label text for the button.
  final String label;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    // Make the button responsive based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return NeoPopButton(
      color: isEnabled ? Theme.of(context).primaryColor : Colors.grey,
      onTapUp: isEnabled && !isLoading ? onTap : null,
      onTapDown: () {},
      // Add depth and shadow configuration for better appearance
      depth: 5,
      child: Padding(
        // Adjust padding based on screen size
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 12 : 15,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // Adjust font size based on screen size
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                // Center text and ensure it doesn't overflow
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
