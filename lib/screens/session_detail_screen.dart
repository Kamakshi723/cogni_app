import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final trackColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;

    final dateStr = DateFormat('MMMM d, yyyy · h:mm a').format(session.createdAt);
    final levelStr = session.levelBefore == session.levelAfter
        ? 'Level ${session.levelAfter}'
        : 'Level ${session.levelBefore} → ${session.levelAfter}';

    String levelChangeLabel;
    if (session.levelChange > 0) {
      levelChangeLabel = '+1 (Level up)';
    } else if (session.levelChange < 0) {
      levelChangeLabel = '-1 (Level down)';
    } else {
      levelChangeLabel = '0 (Level held)';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textPrimary),
        title: Text(
          'Session',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s4),
              Text(
                'Colour Stroop · $levelStr',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.s20),

              // Score Card
              CogniCard(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '${session.score}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: accent,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        'out of 100',
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.s24),

              // Speed Bar
              _buildProgressRow('Speed', session.speed, accent, trackColor, textPrimary, textSecondary),
              const SizedBox(height: AppTheme.s16),

              // Accuracy Bar
              _buildProgressRow('Accuracy', session.accuracy, accent, trackColor, textPrimary, textSecondary, isPercent: true),
              const SizedBox(height: AppTheme.s24),

              // Stats Breakdown
              CogniCard(
                child: Column(
                  children: [
                    _buildStatLine('Median RT', '${session.medianRT} ms', textPrimary, textSecondary),
                    const Divider(height: 24),
                    _buildStatLine('Trials', '${session.totalTrials} (${session.scoredTrials} scored)', textPrimary, textSecondary),
                    const Divider(height: 24),
                    _buildStatLine('Correct', '${session.correctTrials} / ${session.scoredTrials}', textPrimary, textSecondary),
                    const Divider(height: 24),
                    _buildStatLine('Timeouts', '${session.timeouts}', textPrimary, textSecondary),
                    const Divider(height: 24),
                    _buildStatLine('Level change', levelChangeLabel, textPrimary, textSecondary),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s32),

              // Notes Section
              Text(
                'NOTES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s8),
              Text(
                'Your score tracks your own change over time. Not a measure of intelligence or health.',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    String label,
    int value,
    Color accent,
    Color track,
    Color textPrimary,
    Color textSecondary, {
    bool isPercent = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
            ),
            Text(
              isPercent ? '$value%' : '$value',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.s8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatLine(String label, String value, Color textPrimary, Color textSecondary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
