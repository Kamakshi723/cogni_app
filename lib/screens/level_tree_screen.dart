import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import 'game_intro_screen.dart';
import 'matrix_level_tree_screen.dart';
import 'speed_tap_level_tree_screen.dart';
import 'radar_level_tree_screen.dart';

class LevelTreeScreen extends StatefulWidget {
  final bool showBackButton;
  final int initialGame;

  const LevelTreeScreen({
    super.key,
    this.showBackButton = true,
    this.initialGame = 0,
  });

  @override
  State<LevelTreeScreen> createState() => _LevelTreeScreenState();
}

class _LevelTreeScreenState extends State<LevelTreeScreen> {
  final ScrollController _scrollController = ScrollController();
  late int _selectedGame;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.initialGame;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final highestUnlocked = StorageService.getHighestUnlockedLevel();
      if (_scrollController.hasClients && highestUnlocked > 2) {
        final targetOffset = ((highestUnlocked - 2) * 140.0).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateStars(int score) {
    if (score >= 85) return 3;
    if (score >= 65) return 2;
    if (score >= 40) return 1;
    return 0;
  }

  void _showLevelDetailSheet(int level, bool isUnlocked, bool isCompleted) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bestScore = StorageService.getBestScoreForLevel(level);
    final stars = _calculateStars(bestScore);

    // Difficulty params calculation
    final trialMs = (2200 - ((level - 1) * 100)).clamp(800, 2200);
    final interferencePct = (45 + ((level - 1) * 3.35)).clamp(45.0, 92.0).toInt();

    String stageName;
    Color stageColor;
    if (level <= 5) {
      stageName = 'Stage 1: Focus Foundations';
      stageColor = const Color(0xFF10B981);
    } else if (level <= 10) {
      stageName = 'Stage 2: Rapid Inhibition';
      stageColor = const Color(0xFF6366F1);
    } else {
      stageName = 'Stage 3: Interference Mastery';
      stageColor = const Color(0xFFF59E0B);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Stage Tag + Level Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: stageColor.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        stageName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: stageColor,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text(
                              'CLEARED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Level $level of 15',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Star Rating Display
                Row(
                  children: List.generate(3, (starIdx) {
                    final isEarned = starIdx < stars;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.star_rounded,
                        size: 28,
                        color: isEarned ? const Color(0xFFFFB800) : (isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Difficulty Parameters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailParam(
                        icon: Icons.timer_outlined,
                        label: 'Trial Speed',
                        val: '${trialMs}ms',
                        color: const Color(0xFF6366F1),
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      _buildDetailParam(
                        icon: Icons.alt_route_rounded,
                        label: 'Interference',
                        val: '$interferencePct%',
                        color: const Color(0xFFEC4899),
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      _buildDetailParam(
                        icon: Icons.military_tech_outlined,
                        label: 'Best Score',
                        val: bestScore > 0 ? '$bestScore' : '--',
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Button
                if (isUnlocked) ...[
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameIntroScreen(level: level),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 24),
                          const SizedBox(width: 8),
                          Text(isCompleted ? 'Replay Level $level' : 'Start Level $level'),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, size: 18, color: textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Pass Level ${level - 1} to unlock',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailParam({
    required IconData icon,
    required String label,
    required String val,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          val,
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
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;

    final highestUnlocked = StorageService.getHighestUnlockedLevel();
    final completedCount = (highestUnlocked - 1).clamp(0, 15);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton ? BackButton(color: textPrimary) : null,
        title: Text(
          _selectedGame == 0
              ? 'Colour Stroop Map'
              : (_selectedGame == 1 ? 'Memory Matrix Map' : 'Speed Tap Map'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGame = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _selectedGame == 0 ? const Color(0xFF6366F1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          boxShadow: _selectedGame == 0
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.palette_rounded,
                              size: 13,
                              color: _selectedGame == 0 ? Colors.white : textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stroop',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedGame == 0 ? Colors.white : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGame = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _selectedGame == 1 ? const Color(0xFF06B6D4) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          boxShadow: _selectedGame == 1
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              size: 13,
                              color: _selectedGame == 1 ? Colors.white : textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Matrix',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedGame == 1 ? Colors.white : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGame = 2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _selectedGame == 2 ? const Color(0xFFF59E0B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          boxShadow: _selectedGame == 2
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.electric_bolt_rounded,
                              size: 13,
                              color: _selectedGame == 2 ? Colors.white : textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Speed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedGame == 2 ? Colors.white : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGame = 3),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _selectedGame == 3 ? const Color(0xFF10B981) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          boxShadow: _selectedGame == 3
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.radar_rounded,
                              size: 13,
                              color: _selectedGame == 3 ? Colors.white : textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Radar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _selectedGame == 3 ? Colors.white : textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _selectedGame == 1
          ? const MatrixLevelTreeScreen(showBackButton: false, showAppBar: false)
          : _selectedGame == 2
              ? const SpeedTapLevelTreeScreen(showBackButton: false, showAppBar: false)
              : _selectedGame == 3
                  ? const RadarLevelTreeScreen(showBackButton: false, showAppBar: false)
                  : SafeArea(
                  child: Column(
          children: [
            // Top Tracker Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: 6),
              child: CogniCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Current: Level $highestUnlocked of 15',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          ),
                          child: Text(
                            '$completedCount / 15 Cleared',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      child: LinearProgressIndicator(
                        value: (completedCount / 15).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Winding Candy Crush Level Journey Map
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: 15,
                itemBuilder: (context, index) {
                  final level = index + 1; // 1 to 15
                  final isCompleted = level < highestUnlocked || StorageService.isLevelCompleted(level);
                  final isCurrent = level == highestUnlocked;
                  final isUnlocked = level <= highestUnlocked;
                  final bestScore = StorageService.getBestScoreForLevel(level);
                  final stars = _calculateStars(bestScore);

                  // S-curve alignment: Left (-0.5), Center (0.0), Right (0.5), Center (0.0)
                  final cycle = index % 4;
                  double xAlignment;
                  if (cycle == 0) {
                    xAlignment = -0.52;
                  } else if (cycle == 1) {
                    xAlignment = 0.0;
                  } else if (cycle == 2) {
                    xAlignment = 0.52;
                  } else {
                    xAlignment = 0.0;
                  }

                  // Next level alignment for connecting path
                  double nextXAlignment = 0.0;
                  if (level < 15) {
                    final nextCycle = (index + 1) % 4;
                    if (nextCycle == 0) {
                      nextXAlignment = -0.52;
                    } else if (nextCycle == 1) {
                      nextXAlignment = 0.0;
                    } else if (nextCycle == 2) {
                      nextXAlignment = 0.52;
                    } else {
                      nextXAlignment = 0.0;
                    }
                  }

                  return Column(
                    children: [
                      // Stage Header Banners
                      if (level == 1) ...[
                        _buildZoneBanner('🌱 STAGE 1: FOCUS FOUNDATIONS', const Color(0xFF10B981)),
                        const SizedBox(height: 16),
                      ] else if (level == 6) ...[
                        const SizedBox(height: 12),
                        _buildZoneBanner('⚡ STAGE 2: RAPID INHIBITION', const Color(0xFF6366F1)),
                        const SizedBox(height: 16),
                      ] else if (level == 11) ...[
                        const SizedBox(height: 12),
                        _buildZoneBanner('🔥 STAGE 3: INTERFERENCE MASTERY', const Color(0xFFF59E0B)),
                        const SizedBox(height: 16),
                      ],

                      // Level Node
                      Align(
                        alignment: Alignment(xAlignment, 0),
                        child: _buildCandyCrushNode(
                          level: level,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          isUnlocked: isUnlocked,
                          stars: stars,
                          bestScore: bestScore,
                          isDark: isDark,
                        ),
                      ),

                      // Connector Road to Next Node (if not last)
                      if (level < 15) ...[
                        _buildTrailConnector(
                          fromX: xAlignment,
                          toX: nextXAlignment,
                          isUnlocked: level < highestUnlocked,
                          accentColor: accent,
                          isDark: isDark,
                        ),
                      ],

                      if (level == 15) ...[
                        const SizedBox(height: 24),
                        _buildZoneBanner('👑 STROOP GRAND MASTER', const Color(0xFFFFD700)),
                        const SizedBox(height: 48),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneBanner(String title, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: accentColor,
        ),
      ),
    );
  }

  Widget _buildCandyCrushNode({
    required int level,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUnlocked,
    required int stars,
    required int bestScore,
    required bool isDark,
  }) {
    final isMilestone = level % 5 == 0;

    return GestureDetector(
      onTap: () => _showLevelDetailSheet(level, isUnlocked, isCompleted),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current Level Floating "PLAY" Badge
          if (isCurrent) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'PLAY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Outer Jewel / 3D Node
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulsing Glow for Current Level
              if (isCurrent) ...[
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],

              // Main Node Circle
              Container(
                width: isCurrent ? 74 : (isMilestone ? 70 : 62),
                height: isCurrent ? 74 : (isMilestone ? 70 : 62),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCompleted
                      ? (isMilestone
                          ? AppColors.goldGradient
                          : const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ))
                      : (isCurrent
                          ? const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null),
                  color: isUnlocked
                      ? null
                      : (isDark ? AppColors.darkSurfaceAlt : const Color(0xFFE2E8F0)),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.white.withValues(alpha: 0.4)
                        : (isCurrent
                            ? Colors.white
                            : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1))),
                    width: isCurrent ? 3.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUnlocked
                          ? (isCompleted
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : const Color(0xFF6366F1).withValues(alpha: 0.3))
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isCompleted
                      ? (isMilestone
                          ? const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 28)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$level',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const Icon(Icons.check, size: 14, color: Colors.white),
                              ],
                            ))
                      : (isCurrent
                          ? Text(
                              '$level',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            )
                          : (isMilestone
                              ? Icon(
                                  Icons.lock_rounded,
                                  size: 20,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 14,
                                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$level',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ))),
                ),
              ),
            ],
          ),

          // Star Ratings beneath completed node
          if (isCompleted) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (starIdx) {
                final isLit = starIdx < stars;
                return Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: isLit ? const Color(0xFFFFB800) : Colors.black12,
                );
              }),
            ),
          ] else ...[
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildTrailConnector({
    required double fromX,
    required double toX,
    required bool isUnlocked,
    required Color accentColor,
    required bool isDark,
  }) {
    return SizedBox(
      height: 44,
      child: CustomPaint(
        size: const Size(double.infinity, 44),
        painter: _PathConnectorPainter(
          fromXAlignment: fromX,
          toXAlignment: toX,
          isUnlocked: isUnlocked,
          accentColor: accentColor,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _PathConnectorPainter extends CustomPainter {
  final double fromXAlignment;
  final double toXAlignment;
  final bool isUnlocked;
  final Color accentColor;
  final bool isDark;

  _PathConnectorPainter({
    required this.fromXAlignment,
    required this.toXAlignment,
    required this.isUnlocked,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double startX = (size.width / 2) + (fromXAlignment * (size.width * 0.42));
    final double endX = (size.width / 2) + (toXAlignment * (size.width * 0.42));

    final path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(
      startX,
      size.height * 0.5,
      endX,
      size.height * 0.5,
      endX,
      size.height,
    );

    // Thick base path
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, bgPaint);

    if (isUnlocked) {
      final activePaint = Paint()
        ..color = accentColor.withValues(alpha: 0.7)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
