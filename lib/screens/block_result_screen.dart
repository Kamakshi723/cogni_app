import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'game_intro_screen.dart';
import 'level_tree_screen.dart';
import 'main_navigation_screen.dart';

class BlockResultScreen extends StatefulWidget {
  final SessionModel session;

  const BlockResultScreen({
    super.key,
    required this.session,
  });

  @override
  State<BlockResultScreen> createState() => _BlockResultScreenState();
}

class _BlockResultScreenState extends State<BlockResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    );
    _springController.forward();
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  int _calculateStars(int score) {
    if (score >= 85) return 3;
    if (score >= 65) return 2;
    if (score >= 40) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

    final session = widget.session;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final stars = _calculateStars(session.score);

    String levelPillText;
    Color levelPillBg = accentSoft;
    Color levelPillTextCol = accent;

    if (session.levelChange > 0) {
      if (session.levelAfter >= 15) {
        levelPillText = '🏆  Grand Master! Max Level 15 Reached';
        levelPillBg = const Color(0xFFFEF3C7);
        levelPillTextCol = const Color(0xFFD97706);
      } else {
        levelPillText = '🎉  Level Unlocked — Level ${session.levelAfter} of 15!';
        levelPillBg = const Color(0xFFDCFCE7);
        levelPillTextCol = const Color(0xFF16A34A);
      }
    } else if (session.levelChange < 0) {
      levelPillText = '●  Level ${session.levelAfter} of 15 — Keep practicing!';
      levelPillBg = AppColors.feedbackMiss.withValues(alpha: 0.15);
      levelPillTextCol = AppColors.feedbackMiss;
    } else {
      levelPillText = '●  Level ${session.levelAfter} of 15 completed';
    }

    final canAdvance = session.score >= 60 && session.accuracy >= 70 && session.levelBefore < 15;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppTheme.s8),

                // Top Celebratory Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Text(
                      'BLOCK COMPLETE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Celebratory Star Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (starIdx) {
                    final isEarned = starIdx < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.star_rounded,
                        size: 38,
                        color: isEarned ? const Color(0xFFFFB800) : (isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Radial Hero Score Card
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      border: Border.all(
                        color: (isDark ? AppColors.darkAccent : AppColors.lightAccent).withValues(alpha: 0.4),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.darkAccent : AppColors.lightAccent).withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${session.score}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'POINTS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Level Change Spring Pill
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: levelPillBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: levelPillTextCol.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      levelPillText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: levelPillTextCol,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2x2 Performance Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildResultTile(
                        icon: Icons.bolt_rounded,
                        iconColor: const Color(0xFF6366F1),
                        label: 'Speed Index',
                        value: '${session.speed}',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppTheme.s12),
                    Expanded(
                      child: _buildResultTile(
                        icon: Icons.track_changes_rounded,
                        iconColor: const Color(0xFF10B981),
                        label: 'Accuracy',
                        value: '${session.accuracy}%',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.s12),
                Row(
                  children: [
                    Expanded(
                      child: _buildResultTile(
                        icon: Icons.timer_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Median RT',
                        value: '${session.medianRT} ms',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppTheme.s12),
                    Expanded(
                      child: _buildResultTile(
                        icon: Icons.alt_route_rounded,
                        iconColor: const Color(0xFFEC4899),
                        label: 'Level Jump',
                        value: session.levelBefore == session.levelAfter
                            ? 'Lv ${session.levelAfter}'
                            : 'Lv ${session.levelBefore} → ${session.levelAfter}',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sync status
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        auth.isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                        size: 14,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        auth.isOffline
                            ? 'Offline — saved locally'
                            : 'Session saved to your profile',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Primary CTA: Next Level
                if (canAdvance) ...[
                  PrimaryButton(
                    label: 'Next Level (Level ${session.levelBefore + 1})',
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameIntroScreen(level: session.levelBefore + 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.s12),
                ],

                // Secondary CTA: Replay Level
                SecondaryButton(
                  label: 'Replay Level ${session.levelBefore}',
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameIntroScreen(level: session.levelBefore),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.s12),

                // Journey Map
                SecondaryButton(
                  label: 'View Level Journey Map',
                  icon: const Icon(Icons.alt_route_rounded, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LevelTreeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.s12),

                // Return to Home
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.s20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: isDark ? null : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
