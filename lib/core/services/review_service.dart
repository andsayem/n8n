import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a Play Store rating at a good moment: right after the user has
/// done something useful on their own server (activated, deactivated or ran
/// a workflow), never on first launch or in demo mode.
///
/// Google applies its own quota, so a request is not a guaranteed dialog.
/// We ask at most [_maxPrompts] times per install, no more often than every
/// [_promptGap], and only after [_successThreshold] successful actions since
/// the previous request.
class ReviewService {
  ReviewService._();

  static const _successThreshold = 3;
  static const _maxPrompts = 3;
  static const _promptGap = Duration(days: 60);

  /// Lets the success snackbar show first so the dialog doesn't cover it.
  static const _delay = Duration(milliseconds: 1500);

  static const _kSuccessCount = 'review_success_count';
  static const _kPromptCount = 'review_prompt_count';
  static const _kLastPrompt = 'review_last_prompt_ms';

  /// Records one successful workflow action and requests a review once the
  /// thresholds are met. Never throws.
  static Future<void> recordSuccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prompts = prefs.getInt(_kPromptCount) ?? 0;
      if (prompts >= _maxPrompts) return;

      final lastMs = prefs.getInt(_kLastPrompt);
      if (lastMs != null &&
          DateTime.now()
                  .difference(DateTime.fromMillisecondsSinceEpoch(lastMs)) <
              _promptGap) {
        return;
      }

      final count = (prefs.getInt(_kSuccessCount) ?? 0) + 1;
      await prefs.setInt(_kSuccessCount, count);
      if (count < _successThreshold) return;

      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;

      await Future.delayed(_delay);
      await review.requestReview();

      await prefs.setInt(_kPromptCount, prompts + 1);
      await prefs.setInt(_kLastPrompt, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_kSuccessCount, 0);
    } catch (_) {
      // A review prompt is never worth breaking the action that triggered it.
    }
  }
}
