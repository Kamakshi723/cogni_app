import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/speed_tap_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import 'speed_tap_intro_screen.dart';

class SpeedTapLevelTreeScreen extends StatefulWidget {
  final bool showBackButton;
  final bool showAppBar;

  const SpeedTapLevelTreeScreen({
    super.key,
    this.showBackButton = true,
    this.showAppBar = true,
  });

  @override
  State<SpeedTapLevelTreeScreen> createState() => _SpeedTapLevelTreeScreenState();
}

class _SpeedTapLevelTreeScreenState extends State<SpeedTapLevelTreeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final highestUnlocked = StorageService.getSpeedTapHighestUnlockedLevel();
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
    final bestScore = StorageService.getSpeedTapBestScoreForLevel(level);
    final stars = _calculateStars(bestScore);

    final config = SpeedTapProvider.levelConfigs[level] ?? SpeedTapProvider.levelConfigs[1]!;

    String stageName;
    Color stageColor;
    if (level <= 5) {
      stageName = 'Stage 1: Reflex Ignition';
      stageColor = const Color(0xFFF59E0B);
    } else if (level <= 10) {
      stageName = 'Stage 2: Impulsive Brake';
      stageColor = const Color(0xFFEF4444);
    } else {
      stageName = 'Stage 3: Sub-Second Reflex Mastery';
      stageColor = const Color(0xFF8B5CF6);
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
                            Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
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
                  'Level $level — Rapid Go/No-Go',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Stars Display
                if (isCompleted && stars > 0) ...[
                  Row(
                    children: List.generate(3, (index) {
                      final filled = index < stars;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 24,
                          color: filled ? const Color(0xFFF59E0B) : (isDark ? Colors.white24 : Colors.black12),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],

                // Level Specs Grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailParam(
                        icon: Icons.timer_outlined,
                        label: 'Tap Window',
                        val: '${config.goWindowMs}ms',
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      _buildDetailParam(
                        icon: Icons.front_hand_rounded,
                        label: 'No-Go Ratio',
                        val: '${(config.noGoRatio * 100).toInt()}%',
                        color: const Color(0xFFEF4444),
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
                        backgroundColor: const Color(0xFFF59E0B),
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
                            builder: (_) => SpeedTapIntroScreen(level: level),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 24),
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
    const accent = Color(0xFFF59E0B);
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;

    final highestUnlocked = StorageService.getSpeedTapHighestUnlockedLevel();
    final completedCount = (highestUnlocked - 1).clamp(0, 15);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: widget.showBackButton ? BackButton(color: textPrimary) : null,
              title: Text(
                'Speed Tap Map',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            )
          : null,
      body: SafeArea(
        top: widget.showAppBar,
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
                                color: Color(0xFFF59E0B),
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
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD97706),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // S-Curve Map Scroll Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                itemCount: 15,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final isUnlocked = level <= highestUnlocked;
                  final isCompleted = level < highestUnlocked || StorageService.isSpeedTapLevelCompleted(level);
                  final isCurrent = level == highestUnlocked;
                  final bestScore = StorageService.getSpeedTapBestScoreForLevel(level);
                  final stars = _calculateStars(bestScore);

                  final cycle = index % 4;
                  double xAlignment = 0.0;
                  if (cycle == 0) {
                    xAlignment = -0.52;
                  } else if (cycle == 1) {
                    xAlignment = 0.0;
                  } else if (cycle == 2) {
                    xAlignment = 0.52;
                  } else {
                    xAlignment = 0.0;
                  }

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
                        _buildZoneBanner('⚡ STAGE 1: REFLEX IGNITION', const Color(0xFFF59E0B)),
                        const SizedBox(height: 16),
                      ] else if (level == 6) ...[
                        const SizedBox(height: 12),
                        _buildZoneBanner('🛑 STAGE 2: IMPULSIVE BRAKE', const Color(0xFFEF4444)),
                        const SizedBox(height: 16),
                      ] else if (level == 11) ...[
                        const SizedBox(height: 12),
                        _buildZoneBanner('👑 STAGE 3: SUB-SECOND REFLEX MASTERY', const Color(0xFF8B5CF6)),
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

                      // Connector Road to Next Node
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
                        _buildZoneBanner('👑 LIGHTNING REFLEX GRAND MASTER', const Color(0xFFFFD700)),
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
    Color nodeGradientStart;
    Color nodeGradientEnd;
    List<BoxShadow> nodeShadow;
    Widget centerIcon;

    if (isCompleted) {
      nodeGradientStart = const Color(0xFFF59E0B);
      nodeGradientEnd = const Color(0xFFD97706);
      nodeShadow = [
        BoxShadow(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
      centerIcon = Text(
        '$level',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );
    } else if (isCurrent) {
      nodeGradientStart = const Color(0xFF10B981);
      nodeGradientEnd = const Color(0xFF059669);
      nodeShadow = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.55),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ];
      centerIcon = const Icon(Icons.flash_on_rounded, size: 28, color: Colors.white);
    } else {
      nodeGradientStart = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
      nodeGradientEnd = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
      nodeShadow = [];
      centerIcon = Icon(
        Icons.lock_rounded,
        size: 20,
        color: isDark ? Colors.white30 : Colors.black26,
      );
    }

    return GestureDetector(
      onTap: () => _showLevelDetailSheet(level, isUnlocked, isCompleted),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stars display
          if (isCompleted) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (starIdx) {
                final hasStar = starIdx < stars;
                return Icon(
                  hasStar ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 15,
                  color: hasStar ? const Color(0xFFF59E0B) : (isDark ? Colors.white24 : Colors.black26),
                );
              }),
            ),
            const SizedBox(height: 4),
          ] else if (isCurrent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: const Text(
                'PLAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ] else ...[
            const SizedBox(height: 19),
          ],

          // Circular Node Button
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [nodeGradientStart, nodeGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isCurrent
                    ? Colors.white
                    : (isCompleted ? Colors.white.withValues(alpha: 0.8) : Colors.transparent),
                width: isCurrent ? 3.5 : 2.0,
              ),
              boxShadow: nodeShadow,
            ),
            child: Center(child: centerIcon),
          ),

          const SizedBox(height: 4),
          Text(
            isCompleted && bestScore > 0 ? '$bestScore pts' : 'Level $level',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? (isDark ? AppColors.darkTextSecondary : const Color(0xFF475569))
                  : (isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8)),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
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
      width: double.infinity,
      child: CustomPaint(
        painter: _SpeedTrailPainter(
          fromX: fromX,
          toX: toX,
          isUnlocked: isUnlocked,
          accentColor: accentColor,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _SpeedTrailPainter extends CustomPainter {
  final double fromX;
  final double toX;
  final bool isUnlocked;
  final Color accentColor;
  final bool isDark;

  _SpeedTrailPainter({
    required this.fromX,
    required this.toX,
    required this.isUnlocked,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = (size.width * 0.5) + (fromX * size.width * 0.45);
    final endX = (size.width * 0.5) + (toX * size.width * 0.45);

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
        ..color = accentColor.withValues(alpha: 0.75)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
