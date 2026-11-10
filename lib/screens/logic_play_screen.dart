import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/logic_game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/timer_bar.dart';
import 'logic_result_screen.dart';

class LogicPlayScreen extends StatefulWidget {
  final bool soundEnabled;
  final bool hapticsEnabled;

  const LogicPlayScreen({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  @override
  State<LogicPlayScreen> createState() => _LogicPlayScreenState();
}

class _LogicPlayScreenState extends State<LogicPlayScreen> {
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
                  style: TextStyle(fontSize: 14, color: textSecondary),
                ),
                const SizedBox(height: AppTheme.s24),
                PrimaryButton(
                  label: 'Keep playing',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() => _dialogOpen = false);
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
                    final logic = Provider.of<LogicGameProvider>(context, listen: false);
                    logic.quitBlock();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Quit block',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getShapeIcon(LogicShape shape) {
    switch (shape) {
      case LogicShape.circle:
        return Icons.circle;
      case LogicShape.square:
        return Icons.crop_square_rounded;
      case LogicShape.triangle:
        return Icons.change_history_rounded;
      case LogicShape.diamond:
        return Icons.square_rounded; // rotated 45 deg in widget
      case LogicShape.star:
        return Icons.star_rounded;
    }
  }

  Widget _buildShapeItem(LogicShape shape, Color color, double size) {
    final icon = _getShapeIcon(shape);
    if (shape == LogicShape.diamond) {
      return Transform.rotate(
        angle: 0.785398, // 45 degrees
        child: Icon(Icons.crop_square_rounded, color: color, size: size * 0.88),
      );
    }
    return Icon(icon, color: color, size: size);
  }

  Widget _buildCardSymbols(LogicCard card, {bool isLarge = false}) {
    final symbolSize = isLarge ? 38.0 : 26.0;
    final color = card.displayColor;

    if (card.count == 1) {
      return Center(child: _buildShapeItem(card.shape, color, symbolSize * 1.3));
    } else if (card.count == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeItem(card.shape, color, symbolSize),
          const SizedBox(width: 8),
          _buildShapeItem(card.shape, color, symbolSize),
        ],
      );
    } else if (card.count == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeItem(card.shape, color, symbolSize * 0.9),
          const SizedBox(width: 6),
          _buildShapeItem(card.shape, color, symbolSize * 0.9),
          const SizedBox(width: 6),
          _buildShapeItem(card.shape, color, symbolSize * 0.9),
        ],
      );
    } else {
      // 4 symbols in 2x2 cluster
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShapeItem(card.shape, color, symbolSize * 0.8),
              const SizedBox(width: 6),
              _buildShapeItem(card.shape, color, symbolSize * 0.8),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShapeItem(card.shape, color, symbolSize * 0.8),
              const SizedBox(width: 6),
              _buildShapeItem(card.shape, color, symbolSize * 0.8),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<LogicGameProvider>(context);

    // Auto navigate to result when finished
    if (game.isFinished && game.lastCompletedSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LogicResultScreen(session: game.lastCompletedSession!),
            ),
          );
        }
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    const accent = Color(0xFF8B5CF6);

    final ruleName = game.activeRule.name.toUpperCase();

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Header Row
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
                    const SizedBox(height: AppTheme.s16),

                    // Timer / Practice Bar
                    if (game.isPractice) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        ),
                        child: const Text(
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

                    const SizedBox(height: AppTheme.s20),

                    // Active Rule Banner
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: game.justSwitchedRule
                            ? const LinearGradient(
                                colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF2E1065), const Color(0xFF3B0764)]
                                    : [const Color(0xFFEDE9FE), const Color(0xFFF3E8FF)],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: game.justSwitchedRule ? const Color(0xFFEC4899) : accent.withValues(alpha: 0.4),
                          width: game.justSwitchedRule ? 2.0 : 1.0,
                        ),
                        boxShadow: game.justSwitchedRule
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            game.justSwitchedRule ? Icons.bolt_rounded : Icons.psychology_rounded,
                            size: 20,
                            color: game.justSwitchedRule ? Colors.white : accent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            game.justSwitchedRule ? '⚡ RULE SHIFT: MATCH $ruleName' : 'MATCH: $ruleName',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: game.justSwitchedRule ? Colors.white : (isDark ? Colors.white : accent),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.s24),

                    // Center Target Card Arena
                    Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 160, maxHeight: 180),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: game.targetCard.displayColor.withValues(alpha: 0.6),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: game.targetCard.displayColor.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'TARGET STIMULUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _buildCardSymbols(game.targetCard, isLarge: true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.s24),

                    // Choice Prompt
                    Center(
                      child: Text(
                        'Select the candidate matching the $ruleName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.s16),

                    // Candidate Cards Grid (3 or 4 options)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: game.candidateCards.length == 3 ? 3 : 2,
                        childAspectRatio: game.candidateCards.length == 3 ? 0.95 : 1.35,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: game.candidateCards.length,
                      itemBuilder: (context, index) {
                        final candidate = game.candidateCards[index];
                        return GestureDetector(
                          onTap: () => game.handleCardTap(
                            candidate,
                            sound: widget.soundEnabled,
                            haptics: widget.hapticsEnabled,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: _buildCardSymbols(candidate, isLarge: false),
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

            // Correct / Miss Flash Overlay
            if (game.flashCorrect) ...[
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ] else if (game.flashWrong) ...[
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
