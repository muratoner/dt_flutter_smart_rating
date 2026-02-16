import 'package:flutter_test/flutter_test.dart';
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';

void main() {
  group('SmartRating Logic Tests', () {
    late SmartRating smartRating;

    setUp(() {
      smartRating = SmartRating();
      smartRating.resetCounters();
      smartRating.initialize(
        SmartRatingConfig(
          appName: 'Test App',
          storeUrl: 'https://test.com',
          minimumSuccessfulRequests: 3,
        ),
      );
    });

    test('Initial success count should be 0', () {
      expect(smartRating.successCount, 0);
    });

    test('Initial failure count should be 0', () {
      expect(smartRating.failureCount, 0);
    });

    test('reportNetworkSuccess should increment successCount', () {
      smartRating.reportNetworkSuccess();
      expect(smartRating.successCount, 1);

      smartRating.reportNetworkSuccess();
      expect(smartRating.successCount, 2);
    });

    test(
      'reportNetworkFailure should increment failureCount and reset successCount',
      () {
        smartRating.reportNetworkSuccess();
        smartRating.reportNetworkSuccess();
        expect(smartRating.successCount, 2);

        smartRating.reportNetworkFailure();
        expect(smartRating.failureCount, 1);
        expect(smartRating.successCount, 0);
        expect(smartRating.hasFailures, true);
      },
    );

    test('resetCounters should clear all counts', () {
      smartRating.reportNetworkSuccess();
      smartRating.reportNetworkFailure();

      smartRating.resetCounters();

      expect(smartRating.successCount, 0);
      expect(smartRating.failureCount, 0);
      expect(smartRating.hasFailures, false);
    });
  });
}
