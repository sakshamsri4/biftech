import 'package:flutter/material.dart';

// CRED-Inspired Color System

// Background Colors
const Color primaryBackground = Color(0xFF121212);
const Color secondaryBackground = Color(0xFF1E1E1E);

// Accent Colors
const Color accentPrimary = Color(0xFF6C63FF); // CRED signature purple
const Color accentSecondary = Color(0xFF8A84FF); // Lighter purple

// Text Colors
const Color textWhite = Colors.white;
const Color textWhite85 = Color(0xD9FFFFFF); // White 85%
const Color textWhite70 = Color(0xB3FFFFFF); // White 70%
const Color textWhite50 = Color(0x80FFFFFF); // White 50%
const Color textWhite30 = Color(0x4DFFFFFF); // White 30%

// Semantic Colors
const Color success = Color(0xFF00B07C); // Deep teal
const Color warning = Color(0xFFFFC043); // Amber
const Color error = Color(0xFFFF5252); // Coral red

// Other Colors
const Color inactive = Color(0xFF2D2D2D); // Dark gray

/// Extension on ColorScheme to provide easy access to CRED colors.
extension CredColorScheme on ColorScheme {
  // Backgrounds
  Color get credPrimaryBackground => primaryBackground;
  Color get credSecondaryBackground => secondaryBackground;

  // Accents
  Color get credAccentPrimary => accentPrimary;
  Color get credAccentSecondary => accentSecondary;

  // Texts
  Color get credTextWhite => textWhite;
  Color get credTextWhite85 => textWhite85;
  Color get credTextWhite70 => textWhite70;
  Color get credTextWhite50 => textWhite50;
  Color get credTextWhite30 => textWhite30;

  // Semantics
  Color get credSuccess => success;
  Color get credWarning => warning;
  Color get credError => error;

  // Others
  Color get credInactive => inactive;
}
