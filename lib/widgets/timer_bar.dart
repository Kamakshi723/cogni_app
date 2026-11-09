import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class TimerBar extends StatelessWidget {
  final double progress; // 1.0 down to 0.0

  const TimerBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkSurfaceAlt : const Color(0xFFE2E8F0);

    // Dynamic color shift based on remaining time
    Color barColor;
    if (progress > 0.45) {
      barColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
    } else if (progress > 0.22) {
      barColor = const Color(0xFFF59E0B); // Amber
    } else {
      barColor = const Color(0xFFEF4444); // Urgent red
    }

    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            boxShadow: [
              BoxShadow(
                color: barColor.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
