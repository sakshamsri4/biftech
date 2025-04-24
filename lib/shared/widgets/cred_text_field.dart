import 'package:biftech/shared/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template cred_text_field}
/// A custom text field with CRED-style design.
/// {@endtemplate}
class CredTextField extends StatefulWidget {
  /// {@macro cred_text_field}
  const CredTextField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    super.key,
  });

  /// The controller for the text field.
  final TextEditingController controller;

  /// The label text for the text field.
  final String labelText;

  /// The hint text for the text field.
  final String? hintText;

  /// The error text to display.
  final String? errorText;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// The keyboard type to use.
  final TextInputType? keyboardType;

  /// The text input action to use.
  final TextInputAction? textInputAction;

  /// The autofill hints to use.
  final Iterable<String>? autofillHints;

  /// The prefix icon to display.
  final Widget? prefixIcon;

  /// The suffix icon to display.
  final Widget? suffixIcon;

  /// The focus node to use.
  final FocusNode? focusNode;

  /// Called when the user submits the text field.
  final ValueChanged<String>? onSubmitted;

  /// The validator function to use.
  final FormFieldValidator<String>? validator;

  /// The auto-validate mode to use.
  final AutovalidateMode? autovalidateMode;

  @override
  State<CredTextField> createState() => _CredTextFieldState();
}

class _CredTextFieldState extends State<CredTextField> {
  bool _obscureText = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = widget.errorText != null;

    // Determine border color based on state
    Color borderColor;
    if (isError) {
      borderColor = error;
    } else if (_isFocused) {
      borderColor = accentPrimary;
    } else {
      borderColor = const Color(0xFF2A2A2A);
    }

    // Determine background color based on state
    Color backgroundColor;
    if (_isFocused) {
      backgroundColor = secondaryBackground;
    } else {
      backgroundColor = const Color(0xFF1A1A1A);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: accentPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Text(
              widget.labelText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: _isFocused ? accentPrimary : textWhite70,
                fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            onSubmitted: widget.onSubmitted,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textWhite,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: accentPrimary,
            cursorWidth: 1.5,
            cursorRadius: const Radius.circular(1),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: textWhite30,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _isFocused ? accentPrimary : textWhite50,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            ),
          ),
          if (isError)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                widget.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
