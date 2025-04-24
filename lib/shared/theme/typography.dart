import 'package:flutter/material.dart';

// CRED-Inspired Typography System

// Font Family
// Flutter automatically uses SF Pro on iOS/macOS and Roboto on Android/Fuchsia.
// No explicit fallback needed in TextStyle for standard system fonts.
const String? fontFamilyPrimary = null; // Use system default

// Heading Text Styles
const TextStyle headingH1 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

const TextStyle headingH2 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.5,
);

const TextStyle headingH3 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.3,
);

// Body Text Styles
const TextStyle bodyLargeRegular = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
  height: 1.5, // Line height
);

const TextStyle bodyLargeMedium = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  letterSpacing: 0,
  height: 1.5,
);

const TextStyle bodyMediumRegular = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
  height: 1.5,
);

const TextStyle bodyMediumMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  letterSpacing: 0,
  height: 1.5,
);

const TextStyle bodySmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.2,
  height: 1.4,
);

// Label Text Styles
const TextStyle labelLarge = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);

const TextStyle labelMedium = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.1,
);

const TextStyle labelSmall = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  // Note: Apply .toUpperCase() to the text string when using this style.
);

/// Extension on TextTheme to provide easy access to CRED typography styles.
/// These styles inherit the color from the base TextTheme.
extension CredTextTheme on TextTheme {
  // Headings - Inherit color from corresponding display/headline styles
  TextStyle? get credH1 => headingH1.copyWith(color: displayLarge?.color);
  TextStyle? get credH2 => headingH2.copyWith(color: displayMedium?.color);
  TextStyle? get credH3 => headingH3.copyWith(color: headlineMedium?.color);

  // Body (Regular weight is default)
  //- Inherit color from corresponding body styles
  TextStyle? get credBodyLarge =>
      bodyLargeRegular.copyWith(color: bodyLarge?.color);
  TextStyle? get credBodyMedium =>
      bodyMediumRegular.copyWith(color: bodyMedium?.color);
  TextStyle? get credBodySmall =>
      bodySmall.copyWith(color: this.bodySmall?.color);

  // Body (Medium Weight) - Inherit color from corresponding body styles
  TextStyle? get credBodyLargeMedium =>
      bodyLargeMedium.copyWith(color: bodyLarge?.color);
  TextStyle? get credBodyMediumMedium =>
      bodyMediumMedium.copyWith(color: bodyMedium?.color);

  // Labels - Inherit color from corresponding label styles
  TextStyle? get credLabelLarge =>
      labelLarge.copyWith(color: this.labelLarge?.color);
  TextStyle? get credLabelMedium =>
      labelMedium.copyWith(color: this.labelMedium?.color);
  TextStyle? get credLabelSmall =>
      labelSmall.copyWith(color: this.labelSmall?.color);
}
