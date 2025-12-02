import 'package:flutter/material.dart';
import '../ui/smart_rating_theme.dart';

class SmartRatingConfig {
  /// The name of the application.
  final String appName;

  /// The URL to the app store (or App ID for platform specific logic if needed).
  final String storeUrl;

  /// The icon of the application to show in the dialog.
  final Widget? appIcon;

  /// The interval between showing the dialog. Default is 30 days.
  final Duration dialogInterval;

  /// The duration to wait after a successful network response before showing the dialog.
  /// Default is 10 minutes.
  final Duration waitDurationAfterSuccess;

  /// The minimum number of consecutive successful network requests before showing the dialog.
  /// Any failed request will reset this counter. Default is 20.
  final int minimumSuccessfulRequests;

  /// Whether to automatically show the dialog based on success count and timer.
  /// If false, you must manually call SmartRating().showRatingDialog().
  /// Default is true.
  final bool autoTrigger;

  /// Localized texts for the dialog.
  final SmartRatingLocalizations localizations;

  /// The navigator key to show the dialog without a context.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The theme for customizing dialog appearance.
  final SmartRatingTheme theme;

  const SmartRatingConfig({
    required this.appName,
    required this.storeUrl,
    this.appIcon,
    this.navigatorKey,
    this.dialogInterval = const Duration(days: 30),
    this.waitDurationAfterSuccess = const Duration(minutes: 10),
    this.minimumSuccessfulRequests = 20,
    this.autoTrigger = true,
    this.localizations = const SmartRatingLocalizations(),
    SmartRatingTheme? theme,
  }) : theme = theme ?? const SmartRatingTheme();
}

class SmartRatingLocalizations {
  final String title;
  final String description;
  final String rateButtonText;
  final String feedbackButtonText;
  final String laterButtonText;
  final String feedbackTitle;
  final String feedbackDescription;
  final String feedbackHint;
  final String submitFeedbackButtonText;
  final String successMessage;

  const SmartRatingLocalizations({
    this.title = 'Enjoying %s?',
    this.description =
        'If you enjoy using %s, would you mind taking a moment to rate it? It won\'t take more than a minute. Thanks for your support!',
    this.rateButtonText = 'Rate Now',
    this.feedbackButtonText = 'Give Feedback',
    this.laterButtonText = 'Remind Me Later',
    this.feedbackTitle = 'We value your feedback',
    this.feedbackDescription = 'Please tell us how we can improve.',
    this.feedbackHint = 'Enter your feedback here...',
    this.submitFeedbackButtonText = 'Submit',
    this.successMessage =
        'We appreciate your feedback and will use it to improve your experience!',
  });
}
