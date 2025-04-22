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
