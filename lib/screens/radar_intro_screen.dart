import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/radar_game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import 'radar_play_screen.dart';

class RadarIntroScreen extends StatelessWidget {
  final int level;

  const RadarIntroScreen({
    super.key,
    required this.level,
  });

  String _getStageName(int lvl) {
    if (lvl <= 5) return 'Stage 1: Orbital Search';
    if (lvl <= 10) return 'Stage 2: High-Density Tracking';
    return 'Stage 3: Deep Peripheral Mastery';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    const accent = Color(0xFF10B981); // Emerald
    const accentDark = Color(0xFF059669);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final config = RadarGameProvider.levelConfigs[level] ?? RadarGameProvider.levelConfigs[1]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: LevelBadge(level: level, isCompact: true),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Focus Radar',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getStageName(level),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentDark,
                ),
              ),
              const SizedBox(height: AppTheme.s20),

              // Level Specs & Metrics
              CogniCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpecTile(
                          icon: Icons.radar_rounded,
                          label: 'Total Orbs',
                          value: '${config.totalOrbs}',
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        _buildSpecTile(
                          icon: Icons.adjust_rounded,
                          label: 'Targets',
                          value: '${config.targetCount}',
                          color: const Color(0xFF06B6D4),
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 38,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        _buildSpecTile(
                          icon: Icons.timelapse_rounded,
                          label: 'Motion Span',
                          value: '${(config.trackingDurationMs / 1000).toStringAsFixed(1)}s',
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: accentDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '2 calibration practice trials + 8 scored tracking trials',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              // Visual 3-Step Walkthrough
              Text(
                'RADAR PROTOCOL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s12),

              _buildStepCard(
                stepNumber: '1',
                title: 'LOCK TARGETS',
                desc: 'Observe the highlighted glowing orbs before motion starts.',
                icon: Icons.track_changes_rounded,
                color: const Color(0xFF10B981),
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: AppTheme.s12),

              _buildStepCard(
                stepNumber: '2',
                title: 'TRACK ORBITAL MOTION',
                desc: 'All orbs blend in and drift chaotically. Expand peripheral awareness to track all targets simultaneously.',
                icon: Icons.motion_photos_on_rounded,
                color: const Color(0xFF06B6D4),
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: AppTheme.s12),

              _buildStepCard(
                stepNumber: '3',
                title: 'IDENTIFY & RECALL',
                desc: 'When the motion freezes, tap all the original targets to confirm their final positions.',
                icon: Icons.touch_app_rounded,
                color: const Color(0xFF6366F1),
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              const SizedBox(height: AppTheme.s24),

              // Start CTA Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  onPressed: () {
                    final provider = Provider.of<RadarGameProvider>(context, listen: false);
                    provider.startBlock(level);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RadarPlayScreen(
                          soundEnabled: auth.user?.soundEnabled ?? true,
                          hapticsEnabled: auth.user?.hapticsEnabled ?? true,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.radar_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Start Level $level',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Soft gaze at the center helps track multiple peripheral objects',
                  style: TextStyle(
                    fontSize: 11,
                    color: textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
