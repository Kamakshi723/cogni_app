import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import 'game_intro_screen.dart';
import 'level_tree_screen.dart';
import 'matrix_intro_screen.dart';
import 'matrix_level_tree_screen.dart';
import 'speed_tap_intro_screen.dart';
import 'speed_tap_level_tree_screen.dart';
import 'radar_intro_screen.dart';
import 'radar_level_tree_screen.dart';

class GamesLibraryScreen extends StatelessWidget {
  const GamesLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final stroopLevel = StorageService.getHighestUnlockedLevel();
    final stroopCompleted = (stroopLevel - 1).clamp(0, 15);
    final stroopBest = StorageService.getBestScoreForLevel(stroopLevel > 1 ? stroopLevel - 1 : 1);

    final matrixLevel = StorageService.getMatrixHighestUnlockedLevel();
    final matrixCompleted = (matrixLevel - 1).clamp(0, 15);
    final matrixBest = StorageService.getMatrixBestScoreForLevel(matrixLevel > 1 ? matrixLevel - 1 : 1);

    final speedTapLevel = StorageService.getSpeedTapHighestUnlockedLevel();
    final speedTapCompleted = (speedTapLevel - 1).clamp(0, 15);
    final speedTapBest = StorageService.getSpeedTapBestScoreForLevel(speedTapLevel > 1 ? speedTapLevel - 1 : 1);

    final radarLevel = StorageService.getRadarHighestUnlockedLevel();
    final radarCompleted = (radarLevel - 1).clamp(0, 15);
    final radarBest = StorageService.getRadarBestScoreForLevel(radarLevel > 1 ? radarLevel - 1 : 1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Games Suite',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SCIENTIFIC FOCUS PROTOCOLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s12),

              // Game 1: Colour Stroop
              _buildActiveGameCard(
                context: context,
                isDark: isDark,
                title: 'Colour Stroop',
                domain: 'Inhibitory Control & Selective Focus',
                level: stroopLevel,
                completed: stroopCompleted,
                bestScore: stroopBest,
                icon: Icons.palette_rounded,
                accentColor: const Color(0xFF6366F1),
                gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameIntroScreen(level: stroopLevel),
                    ),
                  );
                },
                onMap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LevelTreeScreen(initialGame: 0),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.s16),

              // Game 2: Memory Matrix
              _buildActiveGameCard(
                context: context,
                isDark: isDark,
                title: 'Memory Matrix',
                domain: 'Spatial Working Memory & Span',
                level: matrixLevel,
                completed: matrixCompleted,
                bestScore: matrixBest,
                icon: Icons.grid_view_rounded,
                accentColor: const Color(0xFF06B6D4),
                gradient: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatrixIntroScreen(level: matrixLevel),
                    ),
                  );
                },
                onMap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MatrixLevelTreeScreen(showBackButton: true),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.s16),

              // Game 3: Speed Tap
              _buildActiveGameCard(
                context: context,
                isDark: isDark,
                title: 'Speed Tap',
                domain: 'Processing Speed & Motor Inhibition',
                level: speedTapLevel,
                completed: speedTapCompleted,
                bestScore: speedTapBest,
                icon: Icons.electric_bolt_rounded,
                accentColor: const Color(0xFFF59E0B),
                gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SpeedTapIntroScreen(level: speedTapLevel),
                    ),
                  );
                },
                onMap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpeedTapLevelTreeScreen(showBackButton: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.s16),

              // Game 4: Focus Radar
              _buildActiveGameCard(
                context: context,
                isDark: isDark,
                title: 'Focus Radar',
                domain: 'Selective Attention & Object Tracking',
                level: radarLevel,
                completed: radarCompleted,
                bestScore: radarBest,
                icon: Icons.radar_rounded,
                accentColor: const Color(0xFF10B981),
                gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RadarIntroScreen(level: radarLevel),
                    ),
                  );
                },
                onMap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RadarLevelTreeScreen(showBackButton: true),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppTheme.s24),

              Text(
                'UPCOMING RESEARCH EXERCISES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s12),

              _buildComingSoonCard(
                title: 'Logic Flow',
                domain: 'Fluid Reasoning & Working Rule Shifting',
                icon: Icons.psychology_rounded,
                color: const Color(0xFF8B5CF6),
                surfaceAlt: surfaceAlt,
                border: border,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              const SizedBox(height: AppTheme.s32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveGameCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String domain,
    required int level,
    required int completed,
    required int bestScore,
    required IconData icon,
    required Color accentColor,
    required List<Color> gradient,
    required VoidCallback onPlay,
    required VoidCallback onMap,
  }) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return CogniCard(
      padding: const EdgeInsets.all(AppTheme.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),

              // Title and Domain
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      domain,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Level Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'Lv $level / 15',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 14, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    '$completed Cleared',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              if (bestScore > 0) ...[
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      'Best: $bestScore pts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Two-button action bar
          Row(
            children: [
              // Level Map button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onMap,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.route_rounded, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Map',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Play Now button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onPlay,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Play Level $level',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard({
    required String title,
    required String domain,
    required IconData icon,
    required Color color,
    required Color surfaceAlt,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  domain,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
            child: Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
