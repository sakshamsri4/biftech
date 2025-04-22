import 'package:flutter/material.dart';

/// {@template neo_text_field}
/// A custom text field with NeoPop styling.
/// {@endtemplate}
class NeoTextField extends StatefulWidget {
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
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

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
        maxHeight: widget.errorText != null ? 80 : 60,
      ),
      child: TextField(
        controller: widget.controller,
        autofillHints: widget.obscureText
            ? [AutofillHints.password]
            : [AutofillHints.email],
        keyboardType: widget.obscureText
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        obscureText: _obscureText,
        onChanged: widget.onChanged,
        // Add text input action to improve keyboard navigation
        textInputAction:
            widget.obscureText ? TextInputAction.done : TextInputAction.next,
        // Adjust style based on screen size
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: widget.errorText,
          // Add password visibility toggle if this is a password field
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
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
