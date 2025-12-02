import 'package:flutter/material.dart';

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

  /// Localized texts for the dialog.
  final SmartRatingLocalizations localizations;

  /// The navigator key to show the dialog without a context.
  final GlobalKey<NavigatorState>? navigatorKey;

  const SmartRatingConfig({
    required this.appName,
    required this.storeUrl,
    this.appIcon,
    this.navigatorKey,
    this.dialogInterval = const Duration(days: 30),
    this.waitDurationAfterSuccess = const Duration(minutes: 10),
    this.localizations = const SmartRatingLocalizations(),
  });
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
    this.successMessage = 'Thank you for your feedback!',
  });
}
