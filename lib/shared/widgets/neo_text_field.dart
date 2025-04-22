import 'package:flutter/material.dart';

/// {@template neo_text_field}
/// A custom text field with NeoPop styling.
/// {@endtemplate}
class NeoTextField extends StatelessWidget {
  /// {@macro neo_text_field}
  const NeoTextField({
    required this.controller,
    required this.labelText,
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The label text for the text field.
  final String labelText;

  /// The error text to display.
  final String? errorText;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Make the text field responsive based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            offset: const Offset(3, 3),
          ),
        ],
      ),
      // Constrain the height to prevent overflow
      constraints: BoxConstraints(
        maxHeight: errorText != null ? 80 : 60,
      ),
      child: TextField(
        controller: controller,
        autofillHints:
            obscureText ? [AutofillHints.password] : [AutofillHints.email],
        keyboardType: obscureText
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        obscureText: obscureText,
        onChanged: onChanged,
        // Add text input action to improve keyboard navigation
        textInputAction:
            obscureText ? TextInputAction.done : TextInputAction.next,
        // Adjust style based on screen size
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          // Adjust error style to prevent overflow
          errorStyle: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            height: 0.8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isSmallScreen ? 12 : 16,
          ),
          // Make the label text responsive
          labelStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
          // Ensure error text is visible but compact
          isDense: true,
        ),
      ),
    );
  }
}
