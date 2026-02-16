import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dt_flutter_smart_rating/src/core/smart_rating_storage.dart';

void main() {
  group('SmartRatingStorage Tests', () {
    late SmartRatingStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = SmartRatingStorage();
    });

    test('should store and retrieve last shown date', () async {
      final now = DateTime.now();
      await storage.setLastShownDate(now);
      final retrieved = await storage.getLastShownDate();

      expect(retrieved?.year, now.year);
      expect(retrieved?.month, now.month);
      expect(retrieved?.day, now.day);
      expect(retrieved?.hour, now.hour);
      expect(retrieved?.minute, now.minute);
    });

    test('should return null if last shown date is not set', () async {
      final retrieved = await storage.getLastShownDate();
      expect(retrieved, isNull);
    });

    test('should store and retrieve last action date', () async {
      final now = DateTime.now();
      await storage.setLastActionDate(now);
      final retrieved = await storage.getLastActionDate();

      expect(retrieved?.year, now.year);
      expect(retrieved?.month, now.month);
      expect(retrieved?.day, now.day);
    });

    test('should return null if last action date is not set', () async {
      final retrieved = await storage.getLastActionDate();
      expect(retrieved, isNull);
    });
  });
}
