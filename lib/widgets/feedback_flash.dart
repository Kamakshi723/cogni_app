import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class FeedbackFlash extends StatelessWidget {
  final FlashState state;

  const FeedbackFlash({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state == FlashState.none) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = state == FlashState.correct;

    final overlayColor = (isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft)
        .withValues(alpha: 0.85);

    return Positioned.fill(
      child: Container(
        color: overlayColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCorrect) ...[
              Icon(
                Icons.check_rounded,
                size: 96,
                color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
            ] else ...[
              const Icon(
                Icons.close_rounded,
                size: 96,
                color: AppColors.feedbackMiss,
              ),
              const SizedBox(height: AppTheme.s8),
              const Text(
                'Miss',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.feedbackMiss,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
