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
    return NeoPopButton(
      color: isEnabled ? Theme.of(context).primaryColor : Colors.grey,
      onTapUp: isEnabled && !isLoading ? onTap : null,
      onTapDown: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
