import 'dart:async';
import 'package:flutter/material.dart';
import 'smart_rating_config.dart';
import 'smart_rating_storage.dart';
import '../ui/rating_dialog.dart';

class SmartRating {
  static final SmartRating _instance = SmartRating._internal();
  factory SmartRating() => _instance;
  SmartRating._internal();

  SmartRatingConfig? _config;
  final SmartRatingStorage _storage = SmartRatingStorage();
  Timer? _successTimer;
  bool _hasFailedRecently = false;

  /// Initialize the SmartRating package with configuration.
  void initialize(SmartRatingConfig config) {
    _config = config;
  }

  /// Report a successful network request.
  /// This resets the failure flag and starts/restarts the timer if not already running.
  void reportNetworkSuccess() {
    if (_config == null) {
      debugPrint('SmartRating not initialized. Call initialize() first.');
      return;
    }

    if (_hasFailedRecently) {
      // If we had a failure recently, we don't start the timer yet.
      // Or maybe we should reset the failure flag?
      // Requirement: "son 10dk içerisinde eğer success dışında bir reponse almadıysa"
      // So if we get success, we are good. But if we HAD a failure, we need to wait until 10 mins of PURE success.
      // Let's say: failure sets a flag. Success checks the flag.
      // Actually, simplest way:
      // On failure: cancel timer, set flag = true.
      // On success: if flag is true, set flag = false, start timer.
      // If flag is false, and timer is running, do nothing (let it finish).
      // If flag is false, and timer is NOT running, start timer.

      // Wait, if I get a success, and I had a failure 1 minute ago.
      // The requirement is "no failure in the last 10 minutes".
      // So every failure should reset the clock.
      // Every success should just be "okay, we are still good".
      // But we need to trigger AFTER 10 minutes of success.
      // So:
      // 1. Start timer on first success.
      // 2. If another success comes, do nothing (timer continues).
      // 3. If failure comes, cancel timer.

      // But wait, what if the user is idle?
      // "network trafiği dinlenmesi ve son 10dk içerisinde eğer success dışında bir reponse almadıysa"
      // This implies active usage.
      // Let's refine:
      // We want to show the dialog if the user has been having a good experience for 10 minutes.
      // So we start a timer on the first success.
      // If the timer completes (10 mins), we check if we can show the dialog.
      // If a failure happens, we cancel the timer.

      if (_hasFailedRecently) {
        _hasFailedRecently = false;
      }
    }

    if (_successTimer == null || !_successTimer!.isActive) {
      _successTimer = Timer(_config!.waitDurationAfterSuccess, () {
        _checkAndShowDialog();
      });
    }
  }

  /// Report a failed network request.
  void reportNetworkFailure() {
    _hasFailedRecently = true;
    _successTimer?.cancel();
    _successTimer = null;
  }

  Future<void> _checkAndShowDialog() async {
    if (_config == null) return;

    final lastShown = await _storage.getLastShownDate();
    final lastAction = await _storage.getLastActionDate();
    final now = DateTime.now();

    // Check if user has already taken action (rated or feedback)
    // Requirement: "1 ay içerisinde eğer çıkan bu diyalog için aksiyon almadıysa tekrar çıkarılsın"
    // This implies if they TOOK action, we might not show it again?
    // Or maybe we show it again after a longer period?
    // Let's assume:
    // If action taken: Don't show again (or maybe after a very long time, but for now let's say never or reset manually).
    // Actually, usually if a user rates, we stop bothering them.
    // But the prompt says "1 ay içerisinde eğer çıkan bu diyalog için aksiyon almadıysa tekrar çıkarılsın".
    // This means if they dismissed it (no action), show again in 1 month.
    // If they TOOK action (rated/feedback), we probably shouldn't show it again soon.

    if (lastAction != null) {
      // User has already rated or given feedback.
      // For now, let's assume we don't show it again.
      return;
    }

    if (lastShown != null) {
      final difference = now.difference(lastShown);
      if (difference < _config!.dialogInterval) {
        return;
      }
    }

    // Show dialog
    final context = _config!.navigatorKey?.currentState?.context;
    if (context != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => RatingDialog(config: _config!),
      ).then((result) {
        _storage.setLastShownDate(DateTime.now());
        if (result != null) {
          // Result could be the rating or feedback action
          _storage.setLastActionDate(DateTime.now());
        }
      });
    } else {
      debugPrint(
        'SmartRating: NavigatorKey not provided or context not mounted. Cannot show dialog.',
      );
    }
  }
}
