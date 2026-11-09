import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/matrix_game_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/timer_bar.dart';
import 'matrix_result_screen.dart';

class MatrixPlayScreen extends StatefulWidget {
  final bool soundEnabled;
  final bool hapticsEnabled;

  const MatrixPlayScreen({
    super.key,
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  @override
  State<MatrixPlayScreen> createState() => _MatrixPlayScreenState();
}

class _MatrixPlayScreenState extends State<MatrixPlayScreen> {
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
                    final matrixGame = Provider.of<MatrixGameProvider>(context, listen: false);
                    matrixGame.quitBlock();
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
    final matrixGame = Provider.of<MatrixGameProvider>(context);

    // If block finished, navigate to MatrixResultScreen
    if (matrixGame.isFinished && matrixGame.lastCompletedSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AuthProvider>(context, listen: false).refreshFromStorage();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MatrixResultScreen(session: matrixGame.lastCompletedSession!),
          ),
        );
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final phase = matrixGame.phase;
    final isMemorize = phase == MatrixPhase.memorize;
    final isRecall = phase == MatrixPhase.recall;
    final gridSize = matrixGame.gridSize;

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
                // Top Row: [✕], [Trial 4 / 10], [Lv 3]
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
                        'Trial ${matrixGame.currentTrialNumber} / ${matrixGame.totalTrials}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    LevelBadge(level: matrixGame.currentLevel, isCompact: true),
                  ],
                ),
                const SizedBox(height: 14),

                // Timer Bar
                TimerBar(progress: matrixGame.timerProgress),
                const SizedBox(height: 16),

                // Phase Status Banner
                _buildPhaseBanner(isMemorize, isRecall, matrixGame, isDark),

                const Spacer(flex: 2),

                // Central Focus Arena: The Grid
                Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: isMemorize ? 0.2 : 0.08),
                            blurRadius: isMemorize ? 28 : 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: matrixGame.totalTiles,
                        itemBuilder: (context, index) {
                          return _buildTile(
                            index: index,
                            matrixGame: matrixGame,
                            isMemorize: isMemorize,
                            isRecall: isRecall,
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Bottom Targets Tracker
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF06B6D4)),
                        const SizedBox(width: 6),
                        Text(
                          isMemorize
                              ? '${matrixGame.targetCount} pattern tiles'
                              : '${matrixGame.selectedIndices.length} / ${matrixGame.targetCount} tiles found',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseBanner(bool isMemorize, bool isRecall, MatrixGameProvider game, bool isDark) {
    if (isMemorize) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'MEMORIZE THE PATTERN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      );
    }

    if (isRecall) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app_rounded, color: Color(0xFF6366F1), size: 18),
            const SizedBox(width: 8),
            Text(
              'TAP THE TILES YOU REMEMBER',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.center,
      child: const Text(
        'Next trial...',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }

  Widget _buildTile({
    required int index,
    required MatrixGameProvider matrixGame,
    required bool isMemorize,
    required bool isRecall,
    required bool isDark,
  }) {
    final isTarget = matrixGame.targetIndices.contains(index);
    final isSelected = matrixGame.selectedIndices.contains(index);
    final isWrong = matrixGame.wrongIndices.contains(index);

    // Styling based on state
    Color tileColor;
    List<BoxShadow>? shadows;
    Widget? tileContent;

    if (isMemorize && isTarget) {
      // Lit tile during memorize
      tileColor = const Color(0xFF06B6D4);
      shadows = [
        BoxShadow(
          color: const Color(0xFF06B6D4).withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
      tileContent = const Icon(Icons.star_rounded, color: Colors.white, size: 22);
    } else if (isSelected) {
      // Correctly recalled tile
      tileColor = const Color(0xFF10B981);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.4),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];
      tileContent = const Icon(Icons.check_rounded, color: Colors.white, size: 24);
    } else if (isWrong) {
      // Mistaken tile
      tileColor = const Color(0xFFEF4444);
      shadows = [
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
          blurRadius: 8,
        ),
      ];
      tileContent = const Icon(Icons.close_rounded, color: Colors.white, size: 22);
    } else {
      // Neutral tile
      tileColor = isDark ? AppColors.darkSurfaceAlt : const Color(0xFFE2E8F0);
      tileContent = null;
    }

    return GestureDetector(
      onTap: () {
        matrixGame.handleTileTap(
          index,
          sound: widget.soundEnabled,
          haptics: widget.hapticsEnabled,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(matrixGame.gridSize == 5 ? 10 : 14),
          border: Border.all(
            color: (isMemorize && isTarget) || isSelected
                ? Colors.white.withValues(alpha: 0.6)
                : (isWrong
                    ? Colors.white.withValues(alpha: 0.6)
                    : (isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1))),
            width: isSelected || (isMemorize && isTarget) ? 2.0 : 1.0,
          ),
          boxShadow: shadows,
        ),
        child: Center(child: tileContent),
      ),
    );
  }
}
