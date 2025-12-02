import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/smart_rating_config.dart';

class RatingDialog extends StatefulWidget {
  final SmartRatingConfig config;

  const RatingDialog({super.key, required this.config});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  bool _showFeedback = false;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleRating(int rating) {
    setState(() {
      _rating = rating;
    });

    if (rating >= 4) {
      // 4-5 stars: Redirect to store
      _redirectToStore();
    } else {
      // 1-3 stars: Show feedback input
      setState(() {
        _showFeedback = true;
      });
    }
  }

  Future<void> _redirectToStore() async {
    final url = Uri.parse(widget.config.storeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch ${widget.config.storeUrl}');
    }
    if (mounted) {
      Navigator.of(context).pop('rated');
    }
  }

  void _submitFeedback() {
    // Here you would typically send the feedback to your backend or a callback.
    // For now, we just close the dialog and return 'feedback'.
    // The package user can handle the result.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.config.localizations.successMessage)),
      );
      Navigator.of(context).pop('feedback: ${_feedbackController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.config.localizations;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.config.appIcon != null) ...[
              widget.config.appIcon!,
              const SizedBox(height: 16),
            ],
            Text(
              _showFeedback
                  ? loc.feedbackTitle
                  : loc.title.replaceAll('%s', widget.config.appName),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _showFeedback
                  ? loc.feedbackDescription
                  : loc.description.replaceAll('%s', widget.config.appName),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (!_showFeedback) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () => _handleRating(index + 1),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.laterButtonText),
              ),
            ] else ...[
              TextField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  hintText: loc.feedbackHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: Text(loc.submitFeedbackButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
