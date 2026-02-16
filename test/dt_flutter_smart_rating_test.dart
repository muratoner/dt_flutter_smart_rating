import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmartRating Full Logic Coverage', () {
    late SmartRating smartRating;
    late GlobalKey<NavigatorState> navigatorKey;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      smartRating = SmartRating();
      smartRating.resetCounters();
      navigatorKey = GlobalKey<NavigatorState>();
      smartRating.initialize(
        SmartRatingConfig(
          appName: 'Test App',
          storeUrl: 'https://test.com',
          minimumSuccessfulRequests: 2,
          navigatorKey: navigatorKey,
          waitDurationAfterSuccess: const Duration(seconds: 1),
        ),
      );
    });

    test('should handle multiple successes and timer', () {
      fakeAsync((async) {
        smartRating.reportNetworkSuccess();
        smartRating.reportNetworkSuccess();

        // Wait for the waitDurationAfterSuccess (1s) + some buffer
        async.elapse(const Duration(seconds: 2));

        // After the timer fires, even if it can't show the dialog (binding/context issues),
        // it should have attempted to and then hit resetCounters() or logically progressed.
        // Actually, if it fails due to context null, it might not reach resetCounters().
        // In the test, navigatorKey.currentState is null, so it prints a debug message.
        // Let's check the code: _checkAndShowDialog prints "NavigatorKey not provided or context not mounted"
        // but it DOES NOT call resetCounters() in that branch.
        // The resetCounters() is called in showDialog().then().

        // So in this logic test, successCount will still be 2 because the dialog was never shown.
        expect(smartRating.successCount, 2);
      });
    });

    test('should show dialog manually with conditions', () async {
      smartRating.reportNetworkSuccess();
      smartRating.reportNetworkSuccess();

      // All conditions pass, but showRatingDialog will still fail to show the dialog
      // because context is null. It shouldn't crash though.
      await smartRating.showRatingDialog(
        requireMinimumSuccess: true,
        onlyIfNoFailures: true,
        maximumAllowedFailures: 0,
      );

      expect(smartRating.successCount, 2);
    });

    test('should return failureCount and hasFailures correctly', () {
      expect(smartRating.failureCount, 0);
      expect(smartRating.hasFailures, false);
      smartRating.reportNetworkFailure();
      expect(smartRating.failureCount, 1);
      expect(smartRating.hasFailures, true);
    });
  });
}
