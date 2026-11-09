import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/matrix_game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import 'matrix_play_screen.dart';

class MatrixIntroScreen extends StatelessWidget {
  final int level;

  const MatrixIntroScreen({
    super.key,
    required this.level,
  });

  String _getStageName(int lvl) {
    if (lvl <= 5) return 'Stage 1: Spatial Foundations';
    if (lvl <= 10) return 'Stage 2: Pattern Recall';
    return 'Stage 3: High-Load Matrix Mastery';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? const Color(0xFF06B6D4) : const Color(0xFF0284C7);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final config = MatrixGameProvider.levelConfigs[level] ?? MatrixGameProvider.levelConfigs[1]!;

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
                'Memory Matrix',
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
                          icon: Icons.grid_view_rounded,
                          label: 'Grid Size',
                          value: '${config.gridSize}×${config.gridSize}',
                          color: const Color(0xFF06B6D4),
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        _buildSpecTile(
                          icon: Icons.lightbulb_rounded,
                          label: 'Targets',
                          value: '${config.targetCount} Tiles',
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        _buildSpecTile(
                          icon: Icons.timer_outlined,
                          label: 'Flash Time',
                          value: '${config.memorizeMs}ms',
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
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF06B6D4)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '10 total trials: 2 warmup trials + 8 scored trials',
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
                'Remember the positions of the glowing tiles, then tap them once they disappear.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textPrimary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: AppTheme.s16),

              // Visual Step-by-Step Demo Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                    _buildDemoStep(
                      step: '1. FLASH',
                      subtitle: 'Memorize tiles',
                      isLit: true,
                      isDark: isDark,
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF06B6D4), size: 20),
                    _buildDemoStep(
                      step: '2. BLANK',
                      subtitle: 'Hold in mind',
                      isLit: false,
                      isDark: isDark,
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Color(0xFF06B6D4), size: 20),
                    _buildDemoStep(
                      step: '3. TAP',
                      subtitle: 'Tap to reveal',
                      isLit: true,
                      hasCheck: true,
                      isDark: isDark,
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
                ),
                onPressed: () {
                  final matrixGame = Provider.of<MatrixGameProvider>(context, listen: false);
                  matrixGame.startBlock(level);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatrixPlayScreen(
                        soundEnabled: auth.user?.soundEnabled ?? true,
                        hapticsEnabled: auth.user?.hapticsEnabled ?? true,
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

  Widget _buildDemoStep({
    required String step,
    required String subtitle,
    required bool isLit,
    bool hasCheck = false,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            children: [
              _buildDemoTile(isLit, hasCheck),
              _buildDemoTile(false, false),
              _buildDemoTile(false, false),
              _buildDemoTile(isLit, hasCheck),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoTile(bool isLit, bool hasCheck) {
    return Container(
      decoration: BoxDecoration(
        color: isLit ? const Color(0xFF06B6D4) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: hasCheck && isLit
          ? const Center(
              child: Icon(Icons.check, size: 10, color: Colors.white),
            )
          : null,
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
