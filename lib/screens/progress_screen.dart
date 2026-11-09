import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import '../widgets/empty_state.dart';
import 'game_intro_screen.dart';
import 'session_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  String _formatSessionDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('h:mm a').format(dt).toLowerCase();

    if (sessionDay == today) {
      return 'Today · $timeStr';
    } else if (sessionDay == yesterday) {
      return 'Yesterday · $timeStr';
    } else {
      final daysAgo = today.difference(sessionDay).inDays;
      if (daysAgo < 7) {
        return '$daysAgo days ago · $timeStr';
      }
      return '${DateFormat('MMM d').format(dt)} · $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final userLevel = user?.level ?? 1;

    final sessions = StorageService.getSessions();

    if (sessions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Progress',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: EmptyState(
            icon: Icons.show_chart_rounded,
            title: 'No sessions yet',
            description: 'Play your first block to start your chart.',
            buttonText: 'Play now',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameIntroScreen(level: userLevel),
                ),
              );
            },
          ),
        ),
      );
    }

    // Chart spots: sessions chronological (from oldest to newest)
    final chronological = sessions.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < chronological.length; i++) {
      spots.add(FlSpot(i.toDouble(), chronological[i].score.toDouble()));
    }

    final bestScore = sessions.map((s) => s.score).reduce(max);
    final totalBlocks = sessions.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Progress',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score over time card
              CogniCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCORE OVER TIME',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.s20),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: border.withValues(alpha: 0.7),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 25,
                                reservedSize: 32,
                                getTitlesWidget: (val, meta) {
                                  return Text(
                                    val.toInt().toString(),
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 11,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: max(1, (spots.length / 5).floor()).toDouble(),
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= spots.length) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 11,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: false,
                              color: accent,
                              barWidth: 2,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                                  radius: 3,
                                  color: accent,
                                  strokeWidth: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s16),

              // 3 Stat Tiles: Level, Blocks, Best
              Row(
                children: [
                  Expanded(
                    child: _buildSmallStatCard('Level', '$userLevel', textPrimary, textSecondary),
                  ),
                  const SizedBox(width: AppTheme.s8),
                  Expanded(
                    child: _buildSmallStatCard('Blocks', '$totalBlocks', textPrimary, textSecondary),
                  ),
                  const SizedBox(width: AppTheme.s8),
                  Expanded(
                    child: _buildSmallStatCard('Best', '$bestScore', textPrimary, textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.s32),

              // Recent Sessions List
              Text(
                'RECENT SESSIONS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: AppTheme.s8),
                itemBuilder: (ctx, index) {
                  final s = sessions[index];
                  final levelStr = s.levelBefore == s.levelAfter
                      ? 'Lv ${s.levelAfter}'
                      : 'Lv ${s.levelBefore} → ${s.levelAfter}';

                  return CogniCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionDetailScreen(session: s),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatSessionDate(s.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${s.score} · $levelStr',
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.s24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatCard(String label, String value, Color textPrimary, Color textSecondary) {
    return CogniCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.s4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
