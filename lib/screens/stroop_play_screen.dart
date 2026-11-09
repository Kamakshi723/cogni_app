import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/stroop_colors.dart';
import '../widgets/colour_button.dart';
import '../widgets/feedback_flash.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/timer_bar.dart';
import 'block_result_screen.dart';

class StroopPlayScreen extends StatefulWidget {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool colorBlindMode;

  const StroopPlayScreen({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.colorBlindMode,
  });

  @override
  State<StroopPlayScreen> createState() => _StroopPlayScreenState();
}

class _StroopPlayScreenState extends State<StroopPlayScreen> {
  bool _dialogOpen = false;

  void _showQuitConfirmDialog() {
    setState(() {
      _dialogOpen = true;
    });

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
                  'Quit this block?',
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
                    Navigator.of(ctx).pop();
                    setState(() {
                      _dialogOpen = false;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.s12),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.feedbackMiss,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    final game = Provider.of<GameProvider>(context, listen: false);
                    game.quitBlock();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Quit block',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
    final game = Provider.of<GameProvider>(context);

    // If block finished, navigate to BlockResultScreen
    if (game.isFinished && game.lastCompletedSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Also refresh user level in auth provider
        Provider.of<AuthProvider>(context, listen: false).refreshFromStorage();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlockResultScreen(session: game.lastCompletedSession!),
          ),
        );
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final wordString = StroopColors.getName(game.currentWord).toUpperCase();
    final inkColorValue = StroopColors.getColor(game.currentInkColor);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_dialogOpen) {
          _showQuitConfirmDialog();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Row: [✕], [Trial 7 / 30], [Lv 3]
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
                            'Trial ${game.currentTrialNumber} / ${game.totalTrials}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        LevelBadge(level: game.currentLevel, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Timer / Warm-up Bar
                    if (game.isPractice) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        ),
                        child: Text(
                          'Practice Round — no timer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ),
                    ] else ...[
                      TimerBar(progress: game.timerProgress),
                    ],

                    const Spacer(flex: 3),

                    // Focus Arena Card
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: inkColorValue.withValues(alpha: 0.16),
                              blurRadius: 28,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              wordString,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w800,
                                color: inkColorValue,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Instruction prompt
                    Center(
                      child: Text(
                        'Tap the font colour, NOT the word',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.s16),

                    // 2x2 Grid of Tactile Colour Buttons
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ColourButton(
                                item: StroopItem.red,
                                showColorBlindSymbol: widget.colorBlindMode,
                                onTap: () => game.handleColorTap(
                                  StroopItem.red,
                                  sound: widget.soundEnabled,
                                  haptics: widget.hapticsEnabled,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: ColourButton(
                                item: StroopItem.green,
                                showColorBlindSymbol: widget.colorBlindMode,
                                onTap: () => game.handleColorTap(
                                  StroopItem.green,
                                  sound: widget.soundEnabled,
                                  haptics: widget.hapticsEnabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.s12),
                        Row(
                          children: [
                            Expanded(
                              child: ColourButton(
                                item: StroopItem.blue,
                                showColorBlindSymbol: widget.colorBlindMode,
                                onTap: () => game.handleColorTap(
                                  StroopItem.blue,
                                  sound: widget.soundEnabled,
                                  haptics: widget.hapticsEnabled,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: ColourButton(
                                item: StroopItem.yellow,
                                showColorBlindSymbol: widget.colorBlindMode,
                                onTap: () => game.handleColorTap(
                                  StroopItem.yellow,
                                  sound: widget.soundEnabled,
                                  haptics: widget.hapticsEnabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.s16),
                  ],
                ),
              ),
            ),

            // Feedback Flash Overlay
            FeedbackFlash(
              state: game.feedbackFlash,
            ),
          ],
        ),
      ),
    );
  }
}
