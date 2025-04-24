import 'package:biftech/shared/theme/colors.dart';
import 'package:biftech/shared/theme/typography.dart';
import 'package:flutter/material.dart';

// CRED-Inspired Dark Theme Data

final credTheme = ThemeData(
  brightness: Brightness.dark,

  // --- Color Scheme ---
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: accentPrimary, // Main interactive elements
    onPrimary: textWhite, // Text/icons on primary color
    secondary: accentSecondary, // Secondary interactive elements
    onSecondary: textWhite, // Text/icons on secondary color
    error: error, // Error indication
    onError: textWhite, // Text/icons on background
    surface: secondaryBackground, // Surface of components like Cards, Sheets
    onSurface: textWhite85, // Text/icons on surface
    // Optional: Define other colors if needed
    // primaryContainer: ...,
    // onPrimaryContainer: ...,
    // secondaryContainer: ...,
    // onSecondaryContainer: ...,
    // tertiary: ...,
    // onTertiary: ...,
    // tertiaryContainer: ...,
    // onTertiaryContainer: ...,
    // errorContainer: ...,
    // onErrorContainer: ...,
    // surfaceVariant: ..., // Use for slightly different surfaces
    // onSurfaceVariant: ...,
    // outline: textWhite50, // Borders, dividers
    // shadow: Colors.black.withAlpha((0.4 * 255).round()), // Shadow color
    // inverseSurface: ...,
    // onInverseSurface: ...,
    // inversePrimary: ...,
    // surfaceTint: accentPrimary, // Tint color for surfaces like AppBar
  ),

  // --- Typography ---
  textTheme: TextTheme(
    // Display (Not directly used in CRED styles, map to headings)
    displayLarge: headingH1.copyWith(color: textWhite), // Map to H1
    displayMedium: headingH2.copyWith(color: textWhite), // Map to H2
    displaySmall:
        headingH3.copyWith(color: textWhite), // Map to H3 (or keep default)

    // Headline (Not directly used in CRED styles, map to headings)
    headlineLarge: headingH1.copyWith(color: textWhite), // Map to H1
    headlineMedium: headingH2.copyWith(color: textWhite), // Map to H2
    headlineSmall: headingH3.copyWith(color: textWhite), // Map to H3

    // Title (Used for AppBar titles, Dialog titles etc.)
    titleLarge: headingH3.copyWith(color: textWhite), // Often similar to H3
    titleMedium: bodyLargeMedium.copyWith(color: textWhite85),
    titleSmall: bodyMediumMedium.copyWith(color: textWhite85),

    // Body
    bodyLarge: bodyLargeRegular.copyWith(color: textWhite85),
    bodyMedium: bodyMediumRegular.copyWith(color: textWhite70),
    bodySmall: bodySmall.copyWith(color: textWhite50),

    // Label (Used for Buttons, Input fields etc.)
    labelLarge: labelLarge.copyWith(color: textWhite), // Buttons
    labelMedium: labelMedium.copyWith(color: textWhite85),
    labelSmall:
        labelSmall.copyWith(color: textWhite70), // Often used for captions
  ).apply(
    // Apply base colors if not specified above
    bodyColor: textWhite85,
    displayColor: textWhite,
    decorationColor: textWhite50,
  ),

  // --- Component Themes ---

  scaffoldBackgroundColor: primaryBackground,

  appBarTheme: AppBarTheme(
    backgroundColor:
        secondaryBackground, // Slightly different from main background
    foregroundColor: textWhite, // Color for icons and title
    elevation: 1, // Subtle elevation
    shadowColor: Colors.black.withAlpha((0.3 * 255).round()),
    titleTextStyle:
        headingH3.copyWith(color: textWhite), // Use H3 style for titles
    iconTheme: const IconThemeData(color: textWhite, size: 24),
    actionsIconTheme: const IconThemeData(color: textWhite, size: 24),
  ),

  cardTheme: CardTheme(
    color: secondaryBackground,
    elevation: 2, // Subtle elevation for cards
    shadowColor: Colors.black.withAlpha((0.4 * 255).round()),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Rounded corners
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentPrimary,
      foregroundColor: textWhite,
      textStyle: labelLarge.copyWith(color: textWhite),
      elevation: 2,
      shadowColor: Colors.black.withAlpha((0.3 * 255).round()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(64, 48), // Ensure decent tap target size
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: accentPrimary, // Use accent for text buttons
      textStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(64, 44),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: textWhite85,
      textStyle: labelLarge.copyWith(color: textWhite85),
      side: const BorderSide(color: textWhite50, width: 1.5), // Subtle border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(64, 48),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor:
        inactive.withAlpha((0.5 * 255).round()), // Darker input background
    hintStyle: bodyMediumRegular.copyWith(color: textWhite50),
    labelStyle: bodyMediumMedium.copyWith(
      color: textWhite70,
    ), // Style for floating labels
    errorStyle: bodySmall.copyWith(color: error),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none, // No border by default when enabled
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: accentPrimary,
        width: 1.5,
      ), // Accent border on focus
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: error, width: 2),
    ),
  ),

  dialogTheme: DialogTheme(
    backgroundColor: secondaryBackground,
    elevation: 4, // Slightly more elevation for dialogs
    shadowColor: Colors.black.withAlpha((0.5 * 255).round()),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: headingH3.copyWith(color: textWhite),
    contentTextStyle: bodyMediumRegular.copyWith(color: textWhite85),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: inactive,
    labelStyle: labelMedium.copyWith(color: textWhite85),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), // Pill shape
    ),
    secondaryLabelStyle:
        labelMedium.copyWith(color: textWhite), // For selected state
    secondarySelectedColor: accentPrimary, // Color when selected
    selectedColor: accentPrimary,
    disabledColor: inactive.withAlpha((0.5 * 255).round()),
    brightness: Brightness.dark, // Ensure contrast is correct
  ),

  dividerTheme: DividerThemeData(
    color: textWhite50.withAlpha((0.3 * 255).round()), // Subtle divider
    thickness: 0.5,
    space: 1, // Minimal space
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: secondaryBackground,
    elevation: 2, // Subtle elevation
    selectedItemColor: accentPrimary,
    unselectedItemColor: textWhite70,
    selectedLabelStyle: labelSmall.copyWith(color: accentPrimary),
    unselectedLabelStyle: labelSmall.copyWith(color: textWhite70),
    type: BottomNavigationBarType.fixed, // Or shifting if preferred
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),

  tabBarTheme: TabBarTheme(
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: accentPrimary, width: 2),
    ),
    indicatorSize: TabBarIndicatorSize.label, // Indicator matches label width
    labelColor: accentPrimary,
    unselectedLabelColor: textWhite70,
    labelStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
    unselectedLabelStyle: labelLarge.copyWith(fontWeight: FontWeight.w600),
  ),

  // --- Other Properties ---
  // Define shadow explicitly if needed beyond elevation defaults
  // boxShadows: [
  //   BoxShadow(color: Colors.black.withAlpha((0.1 * 255).round()),
  // blurRadius: 4, offset: Offset(0, 2)),
  //   BoxShadow(color: Colors.black.withAlpha((0.2 * 255).round()),
  //blurRadius: 10, offset: Offset(0, 5)),
  // ],

  // Use Material 3 features if desired (can affect visuals)
  useMaterial3: true,

  // Define visual density for compactness
  visualDensity: VisualDensity.standard, // Or .compact, .comfortable

  // Define splash and highlight colors
  splashColor: accentSecondary.withAlpha((0.2 * 255).round()),
  highlightColor: accentSecondary.withAlpha((0.1 * 255).round()),
);
