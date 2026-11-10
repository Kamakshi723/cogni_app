import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'logic_intro_screen.dart';
import 'logic_level_tree_screen.dart';
import 'main_navigation_screen.dart';

class LogicResultScreen extends StatefulWidget {
  final SessionModel session;

  const LogicResultScreen({
    super.key,
    required this.session,
  });

  @override
  State<LogicResultScreen> createState() => _LogicResultScreenState();
}

class _LogicResultScreenState extends State<LogicResultScreen> with SingleTickerProviderStateMixin {
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

    final session = widget.session;
    final score = session.score;
    final stars = _calculateStars(score);
    final isPassed = score >= 60;
    final hasNextLevel = session.levelAfter > session.levelBefore && session.levelAfter <= 15;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.s8),

              // Title
              Text(
                'Logic Flow Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${session.levelBefore} Fluid Reasoning Performance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Star Rating Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final filled = index < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                      color: filled ? const Color(0xFF8B5CF6) : (isDark ? Colors.white24 : Colors.black12),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Hero Radial Score Dial
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isPassed
                            ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
                            : [const Color(0xFF64748B), const Color(0xFF475569)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPassed ? const Color(0xFF8B5CF6) : Colors.black).withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.0,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Text(
                            'REASONING SCORE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Advancement Status Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(
                      color: isPassed
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPassed ? Icons.psychology_rounded : Icons.replay_rounded,
                        size: 16,
                        color: isPassed ? const Color(0xFF10B981) : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isPassed
                            ? (hasNextLevel
                                ? 'LEVEL ${session.levelAfter} UNLOCKED! 🧠'
                                : 'LOGIC MASTER REACHED! 👑')
                            : 'NEED 60+ TO UNLOCK NEXT LEVEL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPassed ? const Color(0xFF10B981) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4 Stat Cards Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppTheme.s12,
                crossAxisSpacing: AppTheme.s12,
                childAspectRatio: 1.5,
                children: [
                  _buildResultTile(
                    icon: Icons.psychology_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'Match Accuracy',
                    value: '${session.accuracy}%',
                    isDark: isDark,
                  ),
                  _buildResultTile(
                    icon: Icons.sync_alt_rounded,
                    iconColor: const Color(0xFF06B6D4),
                    label: 'Flexibility Index',
                    value: '${session.speed} / 100',
                    isDark: isDark,
                  ),
                  _buildResultTile(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Decision Speed',
                    value: '${session.medianRT}ms',
                    isDark: isDark,
                  ),
                  _buildResultTile(
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'Correct Sorts',
                    value: '${session.correctTrials} / ${session.scoredTrials}',
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (hasNextLevel && isPassed) ...[
                PrimaryButton(
                  label: 'Next Level ${session.levelAfter}',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogicIntroScreen(level: session.levelAfter),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.s12),
              ] else ...[
                PrimaryButton(
                  label: isPassed ? 'Replay Level ${session.levelBefore}' : 'Try Again',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogicIntroScreen(level: session.levelBefore),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.s12),
              ],

              SecondaryButton(
                label: 'View Logic Flow Map',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LogicLevelTreeScreen(showBackButton: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.s12),

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
