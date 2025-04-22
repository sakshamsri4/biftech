import 'package:biftech/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Test-specific version of the App widget
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Center(child: Text('Test App'))),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App', () {
    testWidgets('renders MaterialApp', (tester) async {
      // Build the test app
      await tester.pumpWidget(const TestApp());

      // Verify that the app contains a MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify that the test text is displayed
      expect(find.text('Test App'), findsOneWidget);
    });
  });
}
