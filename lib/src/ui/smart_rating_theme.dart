import 'package:flutter/material.dart';

/// Theme configuration for the Rating Dialog
class SmartRatingTheme {
  // Dialog appearance
  final Color backgroundColor;
  final double borderRadius;
  final List<Color>? backgroundGradient;
  final List<BoxShadow>? shadows;

  // Header
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final EdgeInsets contentPadding;

  // Stars
  final Color starColor;
  final Color starBorderColor;
  final double starSize;
  final double starSpacing;

  // Buttons
  final TextStyle? primaryButtonTextStyle;
  final TextStyle? secondaryButtonTextStyle;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final double buttonBorderRadius;
  final EdgeInsets buttonPadding;

  // Feedback
  final TextStyle? feedbackHintStyle;
  final Color? feedbackBorderColor;
  final Color? feedbackFocusedBorderColor;
  final double feedbackBorderRadius;

  // Icon
  final double iconSize;
  final EdgeInsets iconPadding;

  const SmartRatingTheme({
    this.backgroundColor = const Color(0xFFF8F9FA),
    this.borderRadius = 24.0,
    this.backgroundGradient,
    this.shadows,
    this.titleStyle,
    this.descriptionStyle,
    this.contentPadding = const EdgeInsets.all(24.0),
    this.starColor = const Color(0xFFFFB800),
    this.starBorderColor = const Color(0xFFFFB800),
    this.starSize = 48.0,
    this.starSpacing = 8.0,
    this.primaryButtonTextStyle,
    this.secondaryButtonTextStyle,
    this.primaryButtonColor,
    this.secondaryButtonColor,
    this.buttonBorderRadius = 12.0,
    this.buttonPadding = const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
    this.feedbackHintStyle,
    this.feedbackBorderColor,
    this.feedbackFocusedBorderColor,
    this.feedbackBorderRadius = 12.0,
    this.iconSize = 64.0,
    this.iconPadding = const EdgeInsets.only(bottom: 16.0),
  });

  /// Modern light theme with gradient
  static SmartRatingTheme modernLight() {
    return SmartRatingTheme(
      backgroundColor: Colors.white,
      borderRadius: 28.0,
      backgroundGradient: [const Color(0xFFF8F9FA), const Color(0xFFFFFFFF)],
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 32.0,
          offset: const Offset(0, 8),
        ),
      ],
      titleStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      descriptionStyle: TextStyle(
        fontSize: 15,
        height: 1.5,
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
        fontWeight: FontWeight.w400,
      ),
      starColor: const Color(0xFFFFB800),
      starSize: 52.0,
      starSpacing: 12.0,
      primaryButtonColor: const Color(0xFF6366F1),
      primaryButtonTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      secondaryButtonTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.6),
      ),
      buttonBorderRadius: 16.0,
      feedbackBorderColor: const Color(0xFFE5E7EB),
      feedbackFocusedBorderColor: const Color(0xFF6366F1),
      feedbackBorderRadius: 16.0,
    );
  }

  /// Dark theme with vibrant accents
  static SmartRatingTheme modernDark() {
    return SmartRatingTheme(
      backgroundColor: const Color(0xFF1F2937),
      borderRadius: 28.0,
      backgroundGradient: [const Color(0xFF1F2937), const Color(0xFF111827)],
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 40.0,
          offset: const Offset(0, 12),
        ),
      ],
      titleStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF9FAFB),
        letterSpacing: -0.5,
      ),
      descriptionStyle: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Color(0xFFD1D5DB),
        fontWeight: FontWeight.w400,
      ),
      starColor: const Color(0xFFFBBF24),
      starSize: 52.0,
      starSpacing: 12.0,
      primaryButtonColor: const Color(0xFF8B5CF6),
      primaryButtonTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      secondaryButtonTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF9CA3AF),
      ),
      buttonBorderRadius: 16.0,
      feedbackBorderColor: const Color(0xFF374151),
      feedbackFocusedBorderColor: const Color(0xFF8B5CF6),
      feedbackBorderRadius: 16.0,
    );
  }

  /// Vibrant gradient theme with high contrast
  static SmartRatingTheme vibrantGradient() {
    return SmartRatingTheme(
      backgroundColor: Colors.white,
      borderRadius: 32.0,
      backgroundGradient: [
        const Color(0xFFFFFFFF),
        const Color(0xFFFFF4E6),
        const Color(0xFFFFE4F1),
      ],
      shadows: [
        BoxShadow(
          color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
          blurRadius: 48.0,
          offset: const Offset(0, 16),
        ),
      ],
      titleStyle: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.8,
      ),
      descriptionStyle: const TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Color(0xFF4B5563),
        fontWeight: FontWeight.w500,
      ),
      starColor: const Color(0xFFFF6B35), // Vibrant orange-red
      starBorderColor: const Color(0xFFFF6B35),
      starSize: 56.0,
      starSpacing: 14.0,
      primaryButtonColor: const Color(0xFF8B5CF6), // Purple
      primaryButtonTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
      secondaryButtonTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
      ),
      buttonBorderRadius: 20.0,
      buttonPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      feedbackBorderColor: const Color(0xFFD1D5DB),
      feedbackFocusedBorderColor: const Color(0xFF8B5CF6),
      feedbackBorderRadius: 18.0,
    );
  }
}
