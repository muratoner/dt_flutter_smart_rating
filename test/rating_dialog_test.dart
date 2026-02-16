import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';
import 'package:dt_flutter_smart_rating/src/ui/rating_dialog.dart';

void main() {
  testWidgets('RatingDialog displays title and stars', (
    WidgetTester tester,
  ) async {
    final config = SmartRatingConfig(
      appName: 'Test App',
      storeUrl: 'https://test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RatingDialog(config: config)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(config.localizations.title.replaceAll('%s', 'Test App')),
      findsOneWidget,
    );
    expect(find.byType(Icon), findsNWidgets(5));
  });

  testWidgets('RatingDialog flows to feedback for low rating', (
    WidgetTester tester,
  ) async {
    final config = SmartRatingConfig(
      appName: 'Test App',
      storeUrl: 'https://test.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RatingDialog(config: config)),
      ),
    );
    await tester.pumpAndSettle();

    // Tap 2nd star
    await tester.tap(find.byType(Icon).at(1));

    // Wait for _handleRating delay (400ms)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text(config.localizations.feedbackTitle), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('RatingDialog closes when later button pressed', (
    WidgetTester tester,
  ) async {
    final config = SmartRatingConfig(appName: 'Test', storeUrl: 'test');

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => RatingDialog(config: config),
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

    final laterButton = find.text(config.localizations.laterButtonText);
    expect(laterButton, findsOneWidget);

    await tester.tap(laterButton);
    await tester.pumpAndSettle();

    expect(find.byType(RatingDialog), findsNothing);
  });
}
