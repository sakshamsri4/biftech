# Biftech

<div align="center">

![Biftech Logo](https://storage.googleapis.com/cms-storage-bucket/6e19fee6b47b36ca613f.png)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.5.0-blue.svg)](https://flutter.dev/)
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
![coverage][coverage_badge]

**A collaborative idea-sharing platform with visual flowcharts and donation-based voting**

[Key Features](#key-features) •
[Screenshots](#screenshots) •
[Architecture](#architecture) •
[Installation](#installation) •
[Testing](#testing) •
[Localization](#localization) •
[Future Improvements](#future-improvements)

</div>

## Overview

Biftech is an innovative platform where users can share ideas through interactive flowcharts, engage in discussions, and support arguments with donations. The app facilitates collaborative problem-solving by allowing users to challenge nodes with counter-arguments and determine winning ideas through a combination of logical merit and community support.

---

## Key Features

- **🔐 Secure Authentication**: Complete login and registration system with persistent sessions
- **📱 Modern UI**: CRED-inspired design system with dark theme and engaging animations
- **🎥 Video Feed**: Browse and interact with user-uploaded video content
- **📊 Interactive Flowcharts**: Visual representation of ideas with node-based discussion trees
- **💬 Commenting System**: Add comments to any node in the flowchart
- **🏆 Challenge & Voting**: Challenge ideas and support arguments with donations
- **💰 Reward Distribution**: Automatic distribution of donations (60% to winner, 20% to app, 20% to platform)
- **🌐 Multi-platform**: Works seamlessly on iOS, Android, Web, and Windows

## Screenshots

<div align="center">
<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/get-started/ios/starter-app.png" width="200" alt="Authentication Screen"/>
      <br />
      <em>Authentication</em>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/flutter/website/main/src/assets/images/docs/get-started/ios/starter-app-incremented.png" width="200" alt="Video Feed"/>
      <br />
      <em>Video Feed</em>
    </td>
    <td align="center">
      <img src="https://docs.flutter.dev/assets/images/docs/ui/layout/lakes.jpg" width="200" alt="Flowchart View"/>
      <br />
      <em>Flowchart View</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://docs.flutter.dev/assets/images/docs/ui/layout/card-flutter-gallery.png" width="200" alt="Comments"/>
      <br />
      <em>Comments</em>
    </td>
    <td align="center">
      <img src="https://docs.flutter.dev/assets/images/docs/ui/layout/pavlova-large.jpg" width="200" alt="Donation"/>
      <br />
      <em>Donation</em>
    </td>
    <td align="center">
      <img src="https://docs.flutter.dev/assets/images/docs/ui/layout/lakes-icons.jpg" width="200" alt="Winner Screen"/>
      <br />
      <em>Winner Screen</em>
    </td>
  </tr>
</table>
</div>

> **Note**: These are placeholder screenshots. Replace them with actual screenshots of your app before submitting.

## Architecture

Biftech is built using a modern, scalable architecture:

- **State Management**: BLoC pattern with Cubit for predictable state flows
- **Dependency Injection**: Service locator pattern for clean dependency management
- **Repository Pattern**: Clear separation between data sources and business logic
- **Feature-first Structure**: Organized by feature modules for better maintainability
- **Clean Architecture**: Separation of concerns with presentation, domain, and data layers

```
lib/
├── app/                  # App initialization and configuration
├── features/             # Feature modules
│   ├── auth/             # Authentication feature
│   ├── video_feed/       # Video feed feature
│   ├── flowchart/        # Flowchart visualization and interaction
│   ├── donation/         # Donation processing
│   └── winner/           # Winner determination and reward distribution
├── l10n/                 # Localization
├── shared/               # Shared components, utilities, and themes
└── main.dart             # Entry point
```

## Installation

### Prerequisites

- Flutter SDK 3.5.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions

### Setup

1. Clone the repository:

```sh
git clone https://github.com/sakshamsri4/biftech.git
cd biftech
```

2. Install dependencies:

```sh
flutter pub get
```

3. Run the app in your preferred flavor:

```sh
# Development
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

_\*Biftech works on iOS, Android, Web, and Windows._

---

## Testing

Biftech maintains high code quality with comprehensive test coverage:

### Running Tests

```sh
# Run all tests with coverage
flutter test --coverage --test-randomize-ordering-seed random

# Generate coverage report (using lcov)
lcov --summary coverage/lcov.info
lcov --list coverage/lcov.info

# Open coverage report
open coverage/index.html
```

### Test Structure

- **Unit Tests**: For business logic and data processing
- **Widget Tests**: For UI components and interactions
- **Integration Tests**: For feature workflows and user journeys

---

## Localization

Biftech supports multiple languages using Flutter's built-in localization system:

### Adding New Strings

1. Add strings to `lib/l10n/arb/app_en.arb`:

```arb
{
  "@@locale": "en",
  "appTitle": "Biftech",
  "@appTitle": {
    "description": "The title of the application"
  }
}
```

2. Use in code:

```dart
Text(context.l10n.appTitle)
```

### Adding New Languages

1. Create a new ARB file (e.g., `app_fr.arb`) in `lib/l10n/arb/`
2. Add the locale to `Info.plist` for iOS support:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>es</string>
    <string>fr</string>
</array>
```

3. Run `flutter gen-l10n --arb-dir="lib/l10n/arb"` to generate translations

## Future Improvements

### Technical Enhancements

- **Real-time Updates**: Implement WebSocket for live flowchart updates
- **Offline Support**: Add offline caching for better user experience
- **Advanced Analytics**: Track user engagement and feature usage
- **CI/CD Pipeline**: Automated testing and deployment workflow
- **Performance Optimization**: Reduce app size and improve loading times

### Feature Roadmap

- **AI-assisted Argument Analysis**: Evaluate argument quality using NLP
- **Enhanced Visualization**: More interactive flowchart layouts and animations
- **Social Features**: User profiles, following, and activity feeds
- **Expanded Payment Options**: Support for multiple payment providers
- **Gamification**: Reputation system and badges for active contributors

---

<div align="center">

**Biftech** • Developed with ❤️ by Your Name

</div>

[coverage_badge]: coverage_badge.svg
[flutter_localizations_link]: https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html
[internationalization_link]: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
