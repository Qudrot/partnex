import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:partnex/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('App starts and smoke test passes', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Basic smoke test to ensure the app initializes correctly without crashing
      // Since the app uses routing, it might land on Splash Screen -> Login Page
      expect(find.byType(app.MyApp), findsOneWidget);
    });
  });
}
