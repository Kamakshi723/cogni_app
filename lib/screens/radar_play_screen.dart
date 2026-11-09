import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/radar_game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import 'radar_result_screen.dart';

class RadarPlayScreen extends StatefulWidget {
  final bool soundEnabled;
  final bool hapticsEnabled;

  const RadarPlayScreen({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  @override
  State<RadarPlayScreen> createState() => _RadarPlayScreenState();
}

class _RadarPlayScreenState extends State<RadarPlayScreen> {
  bool _dialogOpen = false;

  void _showQuitConfirmDialog() {
    setState(() => _dialogOpen = true);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quit Focus Radar session?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.s8),
                Text(
                  "Your current block progress and score won't be saved.",
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.s24),
                PrimaryButton(
                  label: 'Keep playing',
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _dialogOpen = false);
                  },
                ),
                const SizedBox(height: AppTheme.s8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final radar = Provider.of<RadarGameProvider>(context, listen: false);
                    radar.quitBlock();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Quit block',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final radar = Provider.of<RadarGameProvider>(context);

    // Auto navigate to result when finished
    if (radar.isFinished && radar.lastCompletedSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RadarResultScreen(
                session: radar.lastCompletedSession!,
              ),
            ),
          );
        }
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_dialogOpen) {
          _showQuitConfirmDialog();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: [✕], [Trial X / 10], [Lv X]
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceAlt : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: textPrimary, size: 22),
                        padding: EdgeInsets.zero,
                        onPressed: _showQuitConfirmDialog,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'Trial ${radar.currentTrialNumber} / ${radar.totalTrials}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    LevelBadge(level: radar.currentLevel, isCompact: true),
                  ],
                ),
                const SizedBox(height: 14),

                // Practice / Scored Indicator
                if (radar.isPractice) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: const Text(
                      'Practice Round — Track and identify highlighted targets',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Phase Status Banner
                _buildPhaseBanner(radar, isDark),
                const SizedBox(height: 16),

                const Spacer(),

                // Central Focus Arena: Orbital Radar Screen
                Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final arenaSize = constraints.maxWidth;
                        final radius = arenaSize / 2;

                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFF0B132B),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              width: 2.0,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Background Radar Rings & Sweeper Painter
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _RadarBackgroundPainter(
                                    sweepAngle: radar.radarSweepAngle,
                                    isTracking: radar.phase == RadarPhase.tracking,
                                  ),
                                ),
                              ),

                              // Drifting Orbs
                              ...radar.orbs.map((orb) {
                                // Convert normalized pos (-1.0 to 1.0) to pixel position
                                final orbX = radius + (orb.position.dx * radius) - 20;
                                final orbY = radius + (orb.position.dy * radius) - 20;

                                return Positioned(
                                  left: orbX,
                                  top: orbY,
                                  child: _buildOrb(orb, radar),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // Helper Footer Text
                Center(
                  child: Text(
                    radar.phase == RadarPhase.recall
                        ? 'Tap all ${radar.targetCount} original targets'
                        : 'Maintain soft peripheral focus across all dots',
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildOrb(RadarOrb orb, RadarGameProvider radar) {
    final phase = radar.phase;
    final isCue = phase == RadarPhase.cue;
    final isRecall = phase == RadarPhase.recall;

    Color orbColor;
    List<BoxShadow> shadows = [];
    Widget? icon;

    if (isCue && orb.isTarget) {
      // Highlighted target during cue
      orbColor = const Color(0xFF10B981);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.8),
          blurRadius: 18,
          spreadRadius: 3,
        ),
      ];
      icon = const Icon(Icons.adjust_rounded, size: 22, color: Colors.white);
    } else if (orb.isSelected) {
      // Correctly selected in recall
      orbColor = const Color(0xFF10B981);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.6),
          blurRadius: 14,
          spreadRadius: 2,
        ),
      ];
      icon = const Icon(Icons.check_rounded, size: 22, color: Colors.white);
    } else if (orb.isWrong) {
      // Mistaken distractor selection
      orbColor = const Color(0xFFEF4444);
      shadows = [
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: 0.5),
          blurRadius: 12,
        ),
      ];
      icon = const Icon(Icons.close_rounded, size: 20, color: Colors.white);
    } else {
      // Blended neutral orb (tracking or unselected recall)
      orbColor = isRecall
          ? const Color(0xFF67E8F9) // Cyan interactive tint in recall
          : const Color(0xFF38BDF8); // Electric sky blue during tracking
      shadows = [
        BoxShadow(
          color: orbColor.withValues(alpha: 0.4),
          blurRadius: 10,
        ),
      ];
      icon = null;
    }

    return GestureDetector(
      onTap: () {
        radar.handleOrbTap(
          orb.id,
          sound: widget.soundEnabled,
          haptics: widget.hapticsEnabled,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: orbColor,
          border: Border.all(
            color: Colors.white,
            width: (isCue && orb.isTarget) || orb.isSelected ? 2.5 : 1.5,
          ),
          boxShadow: shadows,
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildPhaseBanner(RadarGameProvider radar, bool isDark) {
    String text;
    Color color;
    IconData icon;

    switch (radar.phase) {
      case RadarPhase.cue:
        text = 'LOCK TARGETS (${radar.targetCount} Targets)';
        color = const Color(0xFF10B981);
        icon = Icons.adjust_rounded;
        break;
      case RadarPhase.tracking:
        text = 'TRACKING ORBITAL MOTION...';
        color = const Color(0xFF06B6D4);
        icon = Icons.motion_photos_on_rounded;
        break;
      case RadarPhase.recall:
        text = 'IDENTIFY TARGETS (${radar.remainingTargets} left)';
        color = const Color(0xFF6366F1);
        icon = Icons.touch_app_rounded;
        break;
      case RadarPhase.trialResult:
        text = radar.remainingTargets == 0 ? 'TARGETS CONFIRMED! 🎯' : 'TRIAL COMPLETE';
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case RadarPhase.idle:
      case RadarPhase.finished:
        text = 'CALIBRATING';
        color = Colors.grey;
        icon = Icons.radar_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarBackgroundPainter extends CustomPainter {
  final double sweepAngle;
  final bool isTracking;

  _RadarBackgroundPainter({
    required this.sweepAngle,
    required this.isTracking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Concentric Range Rings
    final ringPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, maxRadius * 0.30, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.58, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.82, ringPaint);

    // Crosshairs
    final crossPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), crossPaint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), crossPaint);

    // Radar Sweeper Beam Line (spins during tracking)
    if (isTracking) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: 0.0,
          endAngle: 2 * pi,
          colors: [
            Colors.transparent,
            const Color(0xFF10B981).withValues(alpha: 0.02),
            const Color(0xFF10B981).withValues(alpha: 0.25),
          ],
          stops: const [0.0, 0.8, 1.0],
          transform: GradientRotation(sweepAngle),
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.82));

      canvas.drawCircle(center, maxRadius * 0.82, sweepPaint);

      final linePaint = Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: 0.6)
        ..strokeWidth = 1.8;

      final endPoint = Offset(
        center.dx + cos(sweepAngle) * (maxRadius * 0.82),
        center.dy + sin(sweepAngle) * (maxRadius * 0.82),
      );

      canvas.drawLine(center, endPoint, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarBackgroundPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.isTracking != isTracking;
  }
}
