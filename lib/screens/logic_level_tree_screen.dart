import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/logic_game_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import 'logic_intro_screen.dart';

class LogicLevelTreeScreen extends StatefulWidget {
  final bool showBackButton;
  final bool showAppBar;

  const LogicLevelTreeScreen({
    super.key,
    this.showBackButton = true,
    this.showAppBar = true,
  });

  @override
  State<LogicLevelTreeScreen> createState() => _LogicLevelTreeScreenState();
}

class _LogicLevelTreeScreenState extends State<LogicLevelTreeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final highestUnlocked = StorageService.getLogicHighestUnlockedLevel();
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
    final bestScore = StorageService.getLogicBestScoreForLevel(level);
    final stars = _calculateStars(bestScore);

    final config = LogicGameProvider.levelConfigs[level] ?? LogicGameProvider.levelConfigs[1]!;

    String stageName;
    Color stageColor;
    if (level <= 5) {
      stageName = 'Stage 1: Rule Ignition';
      stageColor = const Color(0xFF8B5CF6);
    } else if (level <= 10) {
      stageName = 'Stage 2: Dynamic Switching';
      stageColor = const Color(0xFFEC4899);
    } else {
      stageName = 'Stage 3: Multidimensional Flux';
      stageColor = const Color(0xFF6366F1);
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
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $level',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          stageName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: stageColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(3, (idx) {
                        final filled = idx < stars;
                        return Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: filled ? const Color(0xFF8B5CF6) : (isDark ? Colors.white24 : Colors.black12),
                          size: 26,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Metrics
                CogniCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailParam(
                        icon: Icons.dashboard_customize_rounded,
                        label: 'Options',
                        val: '${config.choicesCount} Choices',
                        color: const Color(0xFF8B5CF6),
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      _buildDetailParam(
                        icon: Icons.timer_outlined,
                        label: 'Time Limit',
                        val: '${config.trialDurationMs}ms',
                        color: const Color(0xFF10B981),
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
                        backgroundColor: const Color(0xFF8B5CF6),
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
                            builder: (_) => LogicIntroScreen(level: level),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.psychology_rounded, size: 24),
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
            fontSize: 11,
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
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;
    const accent = Color(0xFF8B5CF6); // Purple

    final highestUnlocked = StorageService.getLogicHighestUnlockedLevel();
    int completedCount = 0;
    for (int i = 1; i <= 15; i++) {
      if (StorageService.isLogicLevelCompleted(i)) completedCount++;
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: widget.showBackButton
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                'Logic Flow',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Progress Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CogniCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.psychology_rounded, color: accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Journey Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  'Current: Level $highestUnlocked / 15',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          ),
                          child: Text(
                            '$completedCount / 15 Cleared',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7C3AED),
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
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
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
                  final isCompleted = level < highestUnlocked || StorageService.isLogicLevelCompleted(level);
                  final isCurrent = level == highestUnlocked;
                  final bestScore = StorageService.getLogicBestScoreForLevel(level);
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
                        _buildZoneBanner('🧠 STAGE 1: RULE IGNITION', const Color(0xFF8B5CF6)),
                        const SizedBox(height: 16),
                      ] else if (level == 6) ...[
                        const SizedBox(height: 12),
                        _buildZoneBanner('⚡ STAGE 2: DYNAMIC SWITCHING', const Color(0xFFEC4899)),
                        const SizedBox(height: 16),
                      ] else if (level == 11) ...[
                        const SizedBox(height: 12),
                        _buildZoneBanner('👑 STAGE 3: MULTIDIMENSIONAL FLUX', const Color(0xFF6366F1)),
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
                        _buildZoneBanner('👑 LOGIC FLOW GRAND MASTER', const Color(0xFFFFD700)),
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
      nodeGradientStart = const Color(0xFF8B5CF6);
      nodeGradientEnd = const Color(0xFF6D28D9);
      nodeShadow = [
        BoxShadow(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
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
      nodeGradientStart = const Color(0xFFEC4899);
      nodeGradientEnd = const Color(0xFFBE185D);
      nodeShadow = [
        BoxShadow(
          color: const Color(0xFFEC4899).withValues(alpha: 0.55),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 8),
        ),
      ];
      centerIcon = const Icon(Icons.psychology_rounded, size: 28, color: Colors.white);
    } else {
      nodeGradientStart = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      nodeGradientEnd = isDark ? const Color(0xFF1E293B) : const Color(0xFF94A3B8);
      nodeShadow = [];
      centerIcon = Icon(
        Icons.lock_rounded,
        size: 22,
        color: isDark ? Colors.white38 : Colors.white70,
      );
    }

    return GestureDetector(
      onTap: () => _showLevelDetailSheet(level, isUnlocked, isCompleted),
      child: Column(
        children: [
          // Node Circle
          Stack(
            alignment: Alignment.center,
            children: [
              if (isCurrent)
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [nodeGradientStart, nodeGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: nodeShadow,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isUnlocked ? 0.35 : 0.1),
                    width: 2.5,
                  ),
                ),
                child: Center(child: centerIcon),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Stars below node
          if (isCompleted)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (starIdx) {
                final filled = starIdx < stars;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: filled ? const Color(0xFF8B5CF6) : (isDark ? Colors.white24 : Colors.black12),
                );
              }),
            )
          else
            Text(
              'Lv $level',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
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
      height: 48,
      child: CustomPaint(
        size: const Size(double.infinity, 48),
        painter: _TrailConnectorPainter(
          fromX: fromX,
          toX: toX,
          isUnlocked: isUnlocked,
          activeColor: accentColor,
          inactiveColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

class _TrailConnectorPainter extends CustomPainter {
  final double fromX;
  final double toX;
  final bool isUnlocked;
  final Color activeColor;
  final Color inactiveColor;

  _TrailConnectorPainter({
    required this.fromX,
    required this.toX,
    required this.isUnlocked,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = Offset(
      (size.width / 2) + (fromX * (size.width / 2)),
      0,
    );
    final endPoint = Offset(
      (size.width / 2) + (toX * (size.width / 2)),
      size.height,
    );

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(
      startPoint.dx,
      size.height * 0.5,
      endPoint.dx,
      size.height * 0.5,
      endPoint.dx,
      endPoint.dy,
    );

    final paint = Paint()
      ..color = isUnlocked ? activeColor : inactiveColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (!isUnlocked) {
      final pathMetrics = path.computeMetrics().first;
      final totalLength = pathMetrics.length;
      const dashWidth = 6.0;
      const dashSpace = 6.0;
      double distance = 0.0;

      while (distance < totalLength) {
        final extract = pathMetrics.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailConnectorPainter oldDelegate) {
    return oldDelegate.fromX != fromX ||
        oldDelegate.toX != toX ||
        oldDelegate.isUnlocked != isUnlocked;
  }
}
