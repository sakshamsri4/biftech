import 'package:biftech/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders correctly', (tester) async {
      // Build the app
      await tester.pumpWidget(const App());

      // Verify that the app builds without errors
      expect(find.byType(App), findsOneWidget);

      // Pump a few frames to allow initialization
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
