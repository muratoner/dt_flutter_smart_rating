import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/smart_rating_config.dart';
import 'smart_rating_theme.dart';
import 'thank_you_dialog.dart';

class RatingDialog extends StatefulWidget {
  final SmartRatingConfig config;

  const RatingDialog({super.key, required this.config});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  int _hoverRating = 0;
  bool _showFeedback = false;
  final TextEditingController _feedbackController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleRating(int rating) {
    setState(() {
      _rating = rating;
    });

    // Small delay for visual feedback
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      if (rating >= 4) {
        _redirectToStore();
      } else {
        setState(() {
          _showFeedback = true;
        });
      }
    });
  }

  Future<void> _redirectToStore() async {
    final url = Uri.parse(widget.config.storeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch ${widget.config.storeUrl}');
    }
    if (!mounted) return;

    // Show thank you dialog before closing
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ThankYouDialog(config: widget.config),
    );

    if (!mounted) return;
    Navigator.of(context).pop('rated');
  }

  Future<void> _submitFeedback() async {
    if (!mounted) return;

    final feedbackText = _feedbackController.text;
    // Close rating dialog
    Navigator.of(context).pop('feedback: $feedbackText');

    // Small delay to ensure dialog is closed
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Show thank you dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ThankYouDialog(config: widget.config),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.config.localizations;
    final theme = widget.config.theme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            gradient: theme.backgroundGradient != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.backgroundGradient!,
                  )
                : null,
            borderRadius: BorderRadius.circular(theme.borderRadius),
            boxShadow:
                theme.shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20.0,
                    offset: const Offset(0, 10),
                  ),
                ],
          ),
          child: Padding(
            padding: theme.contentPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.config.appIcon != null) ...[
                  Padding(
                    padding: theme.iconPadding,
                    child: SizedBox(
                      width: theme.iconSize,
                      height: theme.iconSize,
                      child: widget.config.appIcon!,
                    ),
                  ),
                ],
                Text(
                  _showFeedback
                      ? loc.feedbackTitle
                      : loc.title.replaceAll('%s', widget.config.appName),
                  style:
                      theme.titleStyle ??
                      const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _showFeedback
                      ? loc.feedbackDescription
                      : loc.description.replaceAll('%s', widget.config.appName),
                  textAlign: TextAlign.center,
                  style:
                      theme.descriptionStyle ??
                      TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 28),
                if (!_showFeedback) ...[
                  _buildStarRating(theme),
                  const SizedBox(height: 24),
                  _buildSecondaryButton(loc.laterButtonText, theme, () {
                    Navigator.of(context).pop();
                  }),
                ] else ...[
                  _buildFeedbackInput(loc, theme),
                  const SizedBox(height: 20),
                  _buildPrimaryButton(
                    loc.submitFeedbackButtonText,
                    theme,
                    _submitFeedback,
                  ),
                  const SizedBox(height: 10),
                  _buildSecondaryButton(loc.laterButtonText, theme, () {
                    Navigator.of(context).pop();
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(SmartRatingTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width and adjust star size if needed
        // Account for scale animation (1.1x) and margins
        final availableWidth =
            constraints.maxWidth - 32; // Extra padding buffer
        final totalStars = 5;
        final totalSpacing = theme.starSpacing * (totalStars - 1);
        final maxStarSize = (availableWidth - totalSpacing) / totalStars;
        // Reduce by 20% to account for scale animation and ensure no overflow
        final effectiveStarSize =
            (maxStarSize < theme.starSize ? maxStarSize : theme.starSize) *
            0.95;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled =
                starIndex <= (_hoverRating > 0 ? _hoverRating : _rating);

            return Flexible(
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoverRating = starIndex),
                onExit: (_) => setState(() => _hoverRating = 0),
                child: GestureDetector(
                  onTap: () => _handleRating(starIndex),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.starSpacing / 2,
                    ),
                    child: AnimatedScale(
                      scale: (_hoverRating == starIndex || _rating == starIndex)
                          ? 1.1
                          : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        isFilled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: effectiveStarSize,
                        color: isFilled
                            ? theme.starColor
                            : theme.starBorderColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFeedbackInput(
    SmartRatingLocalizations loc,
    SmartRatingTheme theme,
  ) {
    return TextField(
      controller: _feedbackController,
      decoration: InputDecoration(
        hintText: loc.feedbackHint,
        hintStyle:
            theme.feedbackHintStyle ?? TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.feedbackBorderRadius),
          borderSide: BorderSide(
            color: theme.feedbackBorderColor ?? Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.feedbackBorderRadius),
          borderSide: BorderSide(
            color: theme.feedbackBorderColor ?? Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(theme.feedbackBorderRadius),
          borderSide: BorderSide(
            color:
                theme.feedbackFocusedBorderColor ??
                theme.primaryButtonColor ??
                Colors.blue,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      maxLines: 3,
      style: const TextStyle(fontSize: 15),
    );
  }

  Widget _buildPrimaryButton(
    String text,
    SmartRatingTheme theme,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
        child: Container(
          padding: theme.buttonPadding,
          decoration: BoxDecoration(
            color: theme.primaryButtonColor ?? Colors.blue,
            borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
            boxShadow: [
              BoxShadow(
                color: (theme.primaryButtonColor ?? Colors.blue).withValues(
                  alpha: 0.3,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style:
                  theme.primaryButtonTextStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    SmartRatingTheme theme,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
        child: Container(
          padding: theme.buttonPadding,
          decoration: BoxDecoration(
            color: theme.secondaryButtonColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(theme.buttonBorderRadius),
            border: Border.all(
              color: (theme.secondaryButtonTextStyle?.color ?? Colors.grey)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style:
                  theme.secondaryButtonTextStyle ??
                  TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
