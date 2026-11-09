import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/stroop_colors.dart';
import '../widgets/cogni_card.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import 'stroop_play_screen.dart';

class GameIntroScreen extends StatelessWidget {
  final int level;

  const GameIntroScreen({
    super.key,
    required this.level,
  });

  String _getStageName(int lvl) {
    if (lvl <= 5) return 'Stage 1: Focus Foundations';
    if (lvl <= 10) return 'Stage 2: Rapid Inhibition';
    return 'Stage 3: Interference Mastery';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Difficulty params
    final trialMs = (2200 - ((level - 1) * 100)).clamp(800, 2200);
    final interferencePct = (45 + ((level - 1) * 3.35)).clamp(45.0, 92.0).toInt();

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
                'Colour Stroop',
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                          value: '30 Trials',
                          color: const Color(0xFF6366F1),
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
                          value: '${trialMs}ms',
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
                          label: 'Interference',
                          value: '$interferencePct%',
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '10 warmup practice trials (untimed) + 20 scored trials',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s20),

              Text(
                'HOW TO PLAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s6),
              Text(
                'Focus on font ink color. Override your impulse to read the text.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textPrimary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: AppTheme.s16),

              // Interactive Visual Sample Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.0,
                  ),
                  boxShadow: isDark ? null : AppTheme.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'STIMULUS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RED',
                          style: TextStyle(
                            color: StroopColors.blue,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('Ink is Blue', style: TextStyle(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF6366F1), size: 22),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E63DD),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3E63DD).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'BLUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap this ✓',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.s14),

              PrimaryButton(
                label: 'Start Level $level',
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                onPressed: () {
                  final game = Provider.of<GameProvider>(context, listen: false);
                  game.startBlock(level);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StroopPlayScreen(
                        soundEnabled: auth.user?.soundEnabled ?? true,
                        hapticsEnabled: auth.user?.hapticsEnabled ?? true,
                        colorBlindMode: auth.user?.colorBlindMode ?? false,
                      ),
                    ),
                  );
                },
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
}
