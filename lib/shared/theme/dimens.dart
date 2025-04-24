/// Defines standard spacing constants used throughout the application.
class AppDimens {
  AppDimens._(); // Private constructor to prevent instantiation.

  // Base unit: 4.0
  static const double spaceUnit = 4;

  // Standard spacing values
  static const double spaceXXS = spaceUnit; // 4.0
  static const double spaceXS = spaceUnit * 2; // 8.0
  static const double spaceS = spaceUnit * 3; // 12.0
  static const double spaceM = spaceUnit * 4; // 16.0
  static const double spaceL = spaceUnit * 5; // 20.0
  static const double spaceXL = spaceUnit * 6; // 24.0
  static const double spaceXXL = spaceUnit * 8; // 32.0
  static const double spaceXXXL = spaceUnit * 10; // 40.0
  static const double spaceXXXXL = spaceUnit * 12; // 48.0

  // Specific use-case spacing (can be added as needed)
  static const double paddingPageHorizontal = spaceXL; // 24.0
  static const double paddingPageVertical = spaceM; // 16.0

  // Radii
  static const double radiusS = 4;
  static const double radiusM = 8;
  static const double radiusL = 12;
  static const double radiusXL = 16;
  static const double radiusXXL = 20;
  static const double radiusCircular = 1000; // For circular elements
}
