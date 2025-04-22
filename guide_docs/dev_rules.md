# Biftech Development Rules

This document outlines the engineering rules, coding standards, and development practices for the Biftech Flutter project.

## 1. 🚀 Git Strategy
- Use feature branches: `feature/<module>`
- No direct commits to main
- Always squash + merge PRs
- Prefix commits: `feat()`, `fix()`, `refactor()`, etc.
- Keep commits atomic and focused on a single change
- Write descriptive commit messages

## 2. 💻 Dart + Flutter Code Rules
- Use `flutter_bloc` for all state management
- Extract common widgets into `shared/widgets/`
- Use `freezed` + `json_serializable` for models
- Strictly follow SOLID and DRY principles
- Run `flutter analyze` before every push
- Format code with `dart format .`
- Use named parameters for better readability
- Prefer const constructors when possible
- Document public APIs with dartdoc comments

## 3. 🎨 UI/UX Guidelines
- Use `neowidget` for building UI components
- Follow CRED-style design: modern, minimal, elegant
- Implement responsive layouts across devices
- Support light/dark theme toggling
- Respect system font scale + accessibility settings
- Maintain consistent spacing and typography
- Use semantic colors from the theme
- Implement smooth animations and transitions

### 3.1 Responsive Design Requirements
- All UI components must adapt to different screen sizes
- Use MediaQuery to get screen dimensions and adjust layouts accordingly
- Handle keyboard appearance explicitly in forms:
  - Use SingleChildScrollView to allow scrolling when keyboard appears
  - Consider hiding non-essential UI elements when keyboard is visible
  - Use GestureDetector to dismiss keyboard when tapping outside inputs
  - ALWAYS test with iOS simulator as it has unique keyboard behavior
  - Use MediaQuery.viewInsets.bottom to detect keyboard height
- Constrain widget sizes to prevent overflow issues
- Test UI on at least three different screen sizes:
  - Small phone (320-360px width)
  - Standard phone (360-420px width)
  - Tablet/desktop (720px+ width)
- Test on all target platforms (Android, iOS, web) before committing
- Use SafeArea to handle system UI elements like notches and status bars

### 3.2 iOS-Specific Requirements
- iOS keyboard behavior differs from Android and requires special handling
- Forms must always implement scrolling to handle keyboard appearance
- Test with the smallest supported iOS device (iPhone SE) with keyboard open
- Ensure all interactive elements remain accessible when keyboard is visible
- Consider using a bottom sheet for complex forms on smaller screens
- Implement keyboard dismissal when tapping outside of text fields

## 4. ✅ Testing Guidelines
- Every Bloc/Cubit must have unit tests in `test/bloc/`
- UI components should have widget tests using `testWidgets`
- Use `bloc_test`, `mocktail`, `flutter_test` libraries
- Prefer TDD where possible (Test → Build → Refactor)
- Log all test case coverage and edge cases in `activity_log.md`
- Aim for high test coverage, especially for business logic
- Mock external dependencies for unit tests
- Test edge cases and error scenarios

## 5. 🔄 Development Workflow
- Each feature should:
  - Be tracked via `activity_log.md`
  - Contain test cases in `test/`
  - Respect app architecture + linting rules
- All issues or bugs must be logged with:
  - What caused it
  - What fixed it
  - File(s) changed
- Conduct code reviews for all PRs
- Update documentation when implementing new features
- Regularly refactor code to maintain quality

## 6. 📱 App Architecture
- Follow a clean architecture approach
- Organize code by features, not by type
- Implement dependency injection for better testability
- Separate UI, business logic, and data layers
- Use repositories for data access
- Handle errors gracefully with proper user feedback
- Implement proper logging for debugging

## 7. 🧪 Pre-Commit Checklist
- Run `flutter analyze` to catch linting issues
- Run tests with `flutter test` to ensure all tests pass
- Manually test the app on at least one device/emulator
- Verify that the app builds and runs without errors
- Check that all TODOs are properly documented
- Ensure all imports are sorted alphabetically
- Verify that barrel files only export existing files

## 8. 🔧 Platform-Specific Setup
- iOS:
  - Ensure Xcode project has proper build configurations
  - Check that all required permissions are added to Info.plist
  - Verify minimum iOS version is set correctly
- Android:
  - Ensure proper permissions are set in AndroidManifest.xml
  - Check that minSdkVersion is set correctly
  - Verify that gradle dependencies are up to date
- Web:
  - Test on multiple browsers (Chrome, Firefox, Safari)
  - Ensure responsive design works on different screen sizes

## 9. 📝 Documentation Standards
- All public APIs must have dartdoc comments
- Update activity_log.md for every significant change
- Document all issues encountered and their solutions
- Keep README.md up to date with setup instructions
- Document any non-obvious code with inline comments
- Create diagrams for complex workflows when necessary
