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
  int _successCount = 0;

  /// Initialize the SmartRating package with configuration.
  void initialize(SmartRatingConfig config) {
    _config = config;
  }

  /// Report a successful network request.
  /// Increments the success counter. When the counter reaches the minimum,
  /// starts a timer to show the dialog (if autoTrigger is enabled).
  void reportNetworkSuccess() {
    if (_config == null) {
      debugPrint('SmartRating not initialized. Call initialize() first.');
      return;
    }

    _successCount++;
    debugPrint(
      'SmartRating: Success count: $_successCount/${_config!.minimumSuccessfulRequests}',
    );

    // Check if we've reached the minimum successful requests
    if (_successCount >= _config!.minimumSuccessfulRequests) {
      // Only auto-trigger if enabled
      if (_config!.autoTrigger) {
        // Start timer if not already running
        if (_successTimer == null || !_successTimer!.isActive) {
          debugPrint(
            'SmartRating: Minimum success count reached. Starting timer for ${_config!.waitDurationAfterSuccess}',
          );
          _successTimer = Timer(_config!.waitDurationAfterSuccess, () {
            _checkAndShowDialog();
          });
        }
      } else {
        debugPrint(
          'SmartRating: Minimum success count reached, but autoTrigger is disabled. Call showRatingDialog() manually.',
        );
      }
    }
  }

  /// Report a failed network request.
  /// Resets the success counter and cancels any pending timer.
  void reportNetworkFailure() {
    debugPrint(
      'SmartRating: Network failure. Resetting success count from $_successCount to 0',
    );
    _successCount = 0;
    _successTimer?.cancel();
    _successTimer = null;
  }

  /// Manually show the rating dialog.
  /// This bypasses the automatic trigger logic but still respects dialogInterval.
  /// Use this when autoTrigger is false or when you want to show the dialog at a specific moment.
  Future<void> showRatingDialog() async {
    if (_config == null) {
      debugPrint('SmartRating not initialized. Call initialize() first.');
      return;
    }

    await _checkAndShowDialog(forceCheck: false);
  }

  Future<void> _checkAndShowDialog({bool forceCheck = false}) async {
    if (_config == null) return;

    final lastShown = await _storage.getLastShownDate();
    final lastAction = await _storage.getLastActionDate();
    final now = DateTime.now();

    // Check if user has taken action (rated/feedback)
    // If they have, respect the dialogInterval before showing again
    if (lastAction != null) {
      final timeSinceAction = now.difference(lastAction);
      if (timeSinceAction < _config!.dialogInterval) {
        debugPrint(
          'SmartRating: User took action ${timeSinceAction.inDays} days ago. Waiting ${_config!.dialogInterval.inDays} days.',
        );
        return;
      }
    }

    // Check if dialog was shown recently (even if no action was taken)
    if (lastShown != null) {
      final difference = now.difference(lastShown);
      if (difference < _config!.dialogInterval) {
        debugPrint(
          'SmartRating: Dialog shown ${difference.inDays} days ago. Waiting ${_config!.dialogInterval.inDays} days.',
        );
        return;
      }
    }

    // Show dialog
    final context = _config!.navigatorKey?.currentState?.context;
    if (context != null && context.mounted) {
      debugPrint('SmartRating: Showing dialog');
      showDialog(
        context: context,
        builder: (context) => RatingDialog(config: _config!),
      ).then((result) {
        _storage.setLastShownDate(DateTime.now());
        if (result != null) {
          _storage.setLastActionDate(DateTime.now());
        }
        // Reset counters after dialog is shown
        _successCount = 0;
        _successTimer?.cancel();
        _successTimer = null;
      });
    } else {
      debugPrint(
        'SmartRating: NavigatorKey not provided or context not mounted. Cannot show dialog.',
      );
    }
  }
}
