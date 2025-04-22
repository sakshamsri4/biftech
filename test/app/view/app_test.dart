import 'package:biftech/app/app.dart';
import 'package:biftech/features/auth/view/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders AuthPage as initial route', (tester) async {
      // Override the navigator observer to track navigation
      final mockObserver = MockNavigatorObserver();

      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: const App(),
          navigatorObservers: [mockObserver],
        ),
      );

      // Wait for all animations to complete
      await tester.pumpAndSettle();

      // The app should initially show the AuthPage
      expect(find.byType(AuthPage), findsOneWidget);
    });
  });
}

// Mock navigator observer for testing navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Simple Mock class for testing
class Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
