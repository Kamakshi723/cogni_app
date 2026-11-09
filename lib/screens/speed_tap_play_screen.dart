import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/speed_tap_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/timer_bar.dart';
import 'speed_tap_result_screen.dart';

class SpeedTapPlayScreen extends StatefulWidget {
  final bool soundEnabled;
  final bool hapticsEnabled;

  const SpeedTapPlayScreen({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  @override
  State<SpeedTapPlayScreen> createState() => _SpeedTapPlayScreenState();
}

class _SpeedTapPlayScreenState extends State<SpeedTapPlayScreen> {
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
                  'Quit Speed Tap session?',
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
                    final speedTap = Provider.of<SpeedTapProvider>(context, listen: false);
                    speedTap.quitBlock();
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
    final speedTap = Provider.of<SpeedTapProvider>(context);

    // Auto navigate to result when finished
    if (speedTap.isFinished && speedTap.lastCompletedSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SpeedTapResultScreen(
                session: speedTap.lastCompletedSession!,
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
                // Top Row: [✕], [Trial X / 16], [Lv X]
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
                        'Trial ${speedTap.currentTrialNumber} / ${speedTap.totalTrials}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    LevelBadge(level: speedTap.currentLevel, isCompact: true),
                  ],
                ),
                const SizedBox(height: 14),

                // Timer Bar
                TimerBar(progress: speedTap.timerProgress),
                const SizedBox(height: 16),

                // Practice / Scored Indicator
                if (speedTap.isPractice) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: const Text(
                      'Practice Trial — Calibrate your reflexes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Spacer(),

                // Central Stimulus Arena (Tap Target)
                Center(
                  child: GestureDetector(
                    onTapDown: (_) {
                      speedTap.handleTap(
                        sound: widget.soundEnabled,
                        haptics: widget.hapticsEnabled,
                      );
                    },
                    child: _buildStimulusTarget(speedTap, isDark),
                  ),
                ),

                const Spacer(),

                // Bottom Status & Tap Feedback Banner
                _buildFeedbackBanner(speedTap, textPrimary, textSecondary, isDark),
                const SizedBox(height: AppTheme.s20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStimulusTarget(SpeedTapProvider speedTap, bool isDark) {
    final phase = speedTap.phase;

    if (phase == SpeedTapPhase.waiting) {
      // Waiting radar circle
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
            width: 2.0,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.adjust_rounded,
                size: 40,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
              const SizedBox(height: 8),
              Text(
                'WAIT FOR IT...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (phase == SpeedTapPhase.stimulusActive) {
      final isGo = speedTap.currentStimulus == SpeedStimulusType.go;
      final isDistractor = speedTap.currentStimulus == SpeedStimulusType.distractor;

      Color mainColor;
      IconData icon;
      String label;
      List<BoxShadow> glow;

      if (isGo) {
        mainColor = const Color(0xFF10B981);
        icon = Icons.electric_bolt_rounded;
        label = 'TAP!';
        glow = [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.6),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ];
      } else if (isDistractor) {
        mainColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        label = 'HOLD!';
        glow = [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ];
      } else {
        mainColor = const Color(0xFFEF4444);
        icon = Icons.front_hand_rounded;
        label = 'HOLD!';
        glow = [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.6),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ];
      }

      return Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: isGo ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isGo ? null : BorderRadius.circular(32),
          color: mainColor,
          boxShadow: glow,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 76, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Feedback state
    final outcome = speedTap.lastOutcome;
    Color fColor = Colors.grey;
    IconData fIcon = Icons.remove;
    String fText = '';

    switch (outcome) {
      case TapOutcome.hit:
        fColor = const Color(0xFF10B981);
        fIcon = Icons.check_circle_rounded;
        fText = '${speedTap.lastReactionTimeMs}ms!';
        break;
      case TapOutcome.falseAlarm:
        fColor = const Color(0xFFEF4444);
        fIcon = Icons.cancel_rounded;
        fText = 'NO-GO!';
        break;
      case TapOutcome.miss:
        fColor = const Color(0xFF94A3B8);
        fIcon = Icons.timer_off_outlined;
        fText = 'TOO SLOW';
        break;
      case TapOutcome.correctInhibit:
        fColor = const Color(0xFF06B6D4);
        fIcon = Icons.shield_rounded;
        fText = 'SAVED!';
        break;
      case TapOutcome.falseStart:
        fColor = const Color(0xFFF59E0B);
        fIcon = Icons.warning_rounded;
        fText = 'TOO EARLY';
        break;
      case null:
        break;
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fColor.withValues(alpha: 0.15),
        border: Border.all(color: fColor, width: 3.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(fIcon, size: 54, color: fColor),
            const SizedBox(height: 8),
            Text(
              fText,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: fColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(
    SpeedTapProvider speedTap,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    String message = 'Tap anywhere when GREEN appears';
    Color bannerColor = textSecondary;

    if (speedTap.phase == SpeedTapPhase.stimulusActive) {
      if (speedTap.currentStimulus == SpeedStimulusType.go) {
        message = 'TAP IMMEDIATELY! ⚡';
        bannerColor = const Color(0xFF10B981);
      } else {
        message = 'DO NOT TAP! ✋';
        bannerColor = const Color(0xFFEF4444);
      }
    } else if (speedTap.phase == SpeedTapPhase.feedback) {
      final outcome = speedTap.lastOutcome;
      if (outcome == TapOutcome.hit) {
        message = '⚡ Lightning Reflex: ${speedTap.lastReactionTimeMs}ms';
        bannerColor = const Color(0xFF10B981);
      } else if (outcome == TapOutcome.falseAlarm) {
        message = '🛑 Commission Error — No-Go Violated';
        bannerColor = const Color(0xFFEF4444);
      } else if (outcome == TapOutcome.correctInhibit) {
        message = '🛡️ Motor Brake Executed Perfectly';
        bannerColor = const Color(0xFF06B6D4);
      } else if (outcome == TapOutcome.falseStart) {
        message = '⚠️ False Start — Wait for the Stimulus';
        bannerColor = const Color(0xFFF59E0B);
      } else if (outcome == TapOutcome.miss) {
        message = '⏱️ Omission — Window Expired';
        bannerColor = const Color(0xFF94A3B8);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3), width: 1.0),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: bannerColor,
        ),
      ),
    );
  }
}
