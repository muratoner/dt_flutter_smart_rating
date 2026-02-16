import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_flutter_smart_rating/dt_flutter_smart_rating.dart';

void main() {
  group('SmartRatingTheme Tests', () {
    test('default constructor should have correct defaults', () {
      const theme = SmartRatingTheme();
      expect(theme.backgroundColor, const Color(0xFFF8F9FA));
      expect(theme.borderRadius, 24.0);
      expect(theme.starColor, const Color(0xFFFFB800));
    });

    test('modernLight should return a theme with specific values', () {
      final theme = SmartRatingTheme.modernLight();
      expect(theme.backgroundColor, Colors.white);
      expect(theme.borderRadius, 28.0);
      expect(theme.primaryButtonColor, const Color(0xFF6366F1));
    });

    test('modernDark should return a theme with specific values', () {
      final theme = SmartRatingTheme.modernDark();
      expect(theme.backgroundColor, const Color(0xFF1F2937));
      expect(theme.primaryButtonColor, const Color(0xFF8B5CF6));
    });

    test('vibrantGradient should return a theme with specific values', () {
      final theme = SmartRatingTheme.vibrantGradient();
      expect(theme.borderRadius, 32.0);
      expect(theme.starColor, const Color(0xFFFF6B35));
    });
  });
}
