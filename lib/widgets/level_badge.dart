import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LevelBadge extends StatelessWidget {
  final int level;
  final int maxLevel;
  final String? customLabel;
  final bool isCompact;

  const LevelBadge({
    super.key,
    required this.level,
    this.maxLevel = 15,
    this.customLabel,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isMax = level >= maxLevel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: isMax
            ? AppColors.goldGradient
            : (isDark
                ? LinearGradient(
                    colors: [
                      AppColors.darkAccent.withValues(alpha: 0.25),
                      AppColors.darkAccent.withValues(alpha: 0.12),
                    ],
                  )
                : const LinearGradient(
                    colors: [
                      Color(0xFFEEF2FF),
                      Color(0xFFE0E7FF),
                    ],
                  )),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: isMax
              ? const Color(0xFFFFD700)
              : (isDark
                  ? AppColors.darkAccent.withValues(alpha: 0.4)
                  : const Color(0xFFC7D2FE)),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMax ? Icons.emoji_events_rounded : Icons.bolt_rounded,
            size: isCompact ? 14 : 16,
            color: isMax
                ? Colors.black87
                : (isDark ? AppColors.darkAccent : AppColors.lightAccent),
          ),
          const SizedBox(width: 4),
          Text(
            customLabel ?? 'Lv $level / $maxLevel',
            style: TextStyle(
              color: isMax
                  ? Colors.black87
                  : (isDark ? AppColors.darkAccent : AppColors.lightAccent),
              fontSize: isCompact ? 12 : 13,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
