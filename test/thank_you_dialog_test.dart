import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';
import 'package:dt_flutter_smart_rating/src/ui/thank_you_dialog.dart';

void main() {
  testWidgets('ThankYouDialog displays correctly', (WidgetTester tester) async {
    final config = SmartRatingConfig(
      appName: 'Test App',
      storeUrl: 'https://test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ThankYouDialog(config: config)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(config.localizations.thankYouMessage), findsOneWidget);
    expect(find.text(config.localizations.successMessage), findsOneWidget);

    // Clear auto-dismiss timer to avoid "Timer is still pending"
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('ThankYouDialog auto-dismisses', (WidgetTester tester) async {
    final config = SmartRatingConfig(
      appName: 'Test App',
      storeUrl: 'https://test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => ThankYouDialog(config: config),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.byType(ThankYouDialog), findsOneWidget);

    // Wait for auto-dismiss (2 seconds)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(ThankYouDialog), findsNothing);
  });
}
