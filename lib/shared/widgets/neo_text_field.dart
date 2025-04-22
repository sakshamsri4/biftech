import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';

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
    return NeoPopTextField(
      controller: controller,
      textFieldConfig: TextFieldConfig(
        autofillHints: obscureText 
            ? [AutofillHints.password]
            : [AutofillHints.email],
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
        ),
      ),
      plunkConfig: PlunkConfig(
        depth: 8,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
