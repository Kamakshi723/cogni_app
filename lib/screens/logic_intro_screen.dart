import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/logic_game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import 'logic_play_screen.dart';

class LogicIntroScreen extends StatelessWidget {
  final int level;

  const LogicIntroScreen({
    super.key,
    required this.level,
  });

  String _getStageName(int lvl) {
    if (lvl <= 5) return 'Stage 1: Rule Ignition';
    if (lvl <= 10) return 'Stage 2: Dynamic Switching';
    return 'Stage 3: Multidimensional Flux';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    const accent = Color(0xFF8B5CF6); // Purple
    const accentDark = Color(0xFF7C3AED);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final config = LogicGameProvider.levelConfigs[level] ?? LogicGameProvider.levelConfigs[1]!;

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
                'Logic Flow',
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
                  color: accent,
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
                          icon: Icons.checklist_rtl_rounded,
                          label: 'Trials',
                          value: '14 Trials',
                          color: accent,
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        _buildSpecTile(
                          icon: Icons.speed_rounded,
                          label: 'Time Limit',
                          value: '${config.trialDurationMs}ms',
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        _buildSpecTile(
                          icon: Icons.alt_route_rounded,
                          label: 'Rule Shift',
                          value: config.switchEvery == 1 ? 'Every Trial' : 'Every ${config.switchEvery}x',
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '2 warmup practice trials (untimed) + 12 scored trials',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFDDD6FE) : accentDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              Text(
                'HOW TO PLAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s12),

              // Step 1: Follow Active Rule
              _buildStepCard(
                stepNumber: '1',
                title: 'FOLLOW ACTIVE RULE',
                desc: 'Look at the top rule banner (e.g. MATCH COLOR or MATCH SHAPE). Only match along that active dimension.',
                icon: Icons.rule_rounded,
                color: accent,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: AppTheme.s12),

              // Step 2: Resist Competing Lures
              _buildStepCard(
                stepNumber: '2',
                title: 'RESIST COMPETING LURES',
                desc: 'Wrong choices deliberately match non-target dimensions (e.g. matching shape when rule is color). Override impulses!',
                icon: Icons.shield_rounded,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              const SizedBox(height: AppTheme.s12),

              // Step 3: Adapt to Dynamic Shifts
              _buildStepCard(
                stepNumber: '3',
                title: 'ADAPT TO RULE SHIFTS',
                desc: 'The rule will suddenly switch mid-block! When the banner pulses, immediately pivot your sorting strategy.',
                icon: Icons.sync_problem_rounded,
                color: const Color(0xFF10B981),
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              const SizedBox(height: AppTheme.s20),

              // Visual Example Demonstration
              CogniCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: const Text(
                        'RULE: MATCH COLOR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Target
                        Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accent, width: 2.0),
                              ),
                              child: const Center(
                                child: Icon(Icons.star_rounded, size: 36, color: Color(0xFF8B5CF6)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Purple Star', style: TextStyle(fontSize: 10, color: textSecondary)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.arrow_forward_rounded, color: accent, size: 20),
                        ),
                        // Match
                        Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF10B981), width: 2.0),
                              ),
                              child: const Center(
                                child: Icon(Icons.crop_square_rounded, size: 36, color: Color(0xFF8B5CF6)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap This ✓',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              Center(
                child: Text(
                  'Quitting mid-block discards session score',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ),
              const SizedBox(height: AppTheme.s16),

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
                    final provider = Provider.of<LogicGameProvider>(context, listen: false);
                    provider.startBlock(level);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogicPlayScreen(
                          soundEnabled: auth.user?.soundEnabled ?? true,
                          hapticsEnabled: auth.user?.hapticsEnabled ?? true,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Start Level $level',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: isDark ? null : AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'STEP $stepNumber',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
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
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
