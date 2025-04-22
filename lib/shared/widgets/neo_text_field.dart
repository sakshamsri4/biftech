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
      child: TextField(
        controller: controller,
        autofillHints:
            obscureText ? [AutofillHints.password] : [AutofillHints.email],
        keyboardType: obscureText
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
