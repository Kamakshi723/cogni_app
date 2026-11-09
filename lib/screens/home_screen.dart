import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_model.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/level_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'auth_screen.dart';
import 'game_intro_screen.dart';
import 'games_library_screen.dart';
import 'level_tree_screen.dart';
import 'matrix_intro_screen.dart';
import 'speed_tap_intro_screen.dart';
import 'radar_intro_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToGames;

  const HomeScreen({
    super.key,
    required this.onNavigateToGames,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatElapsedTime(DateTime? time) {
    if (time == null) return 'Ready for your first session';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Played just now';
    if (diff.inMinutes < 60) return 'Played ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Played ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Played yesterday';
    return 'Played ${diff.inDays} days ago';
  }

  String _getStageName(int level) {
    if (level <= 5) return 'Stage 1: Focus Foundations';
    if (level <= 10) return 'Stage 2: Rapid Inhibition';
    return 'Stage 3: Interference Mastery';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final surfaceAlt = isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Kashish';
    final highestUnlocked = StorageService.getHighestUnlockedLevel();
    final matrixHighestUnlocked = StorageService.getMatrixHighestUnlockedLevel();
    final speedTapHighestUnlocked = StorageService.getSpeedTapHighestUnlockedLevel();
    final radarHighestUnlocked = StorageService.getRadarHighestUnlockedLevel();
    final completedCount = (highestUnlocked - 1).clamp(0, 15);
    final isGuest = user?.isGuest ?? false;
    final isOffline = auth.isOffline;

    final sessions = StorageService.getSessions();
    final SessionModel? lastSession = sessions.isNotEmpty ? sessions.first : null;
    final int bestScore = sessions.isNotEmpty
        ? sessions.map((s) => s.score).reduce((a, b) => a > b ? a : b)
        : 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Greeting + Streak + Profile Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Daily Streak Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      border: Border.all(color: const Color(0xFFFDBA74), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 15)),
                        SizedBox(width: 5),
                        Text(
                          '3 Days',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  LevelBadge(level: highestUnlocked, isCompact: true),
                ],
              ),
              const SizedBox(height: AppTheme.s16),

              // Offline variant strip
              if (isOffline) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.s12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackMiss.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.feedbackMiss.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.feedbackMiss),
                      const SizedBox(width: AppTheme.s8),
                      Expanded(
                        child: Text(
                          "Offline mode — sessions will sync once reconnected",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFFFD580) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Guest banner
              if (isGuest) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.s16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceAlt : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFC7D2FE),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.lightAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Playing as guest. Sign in to sync your level journey.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthScreen(initialIsLogin: false),
                            ),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // HERO CARD: Colour Stroop Level Quest
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4338CA), // Deep Indigo
                      Color(0xFF312E81), // Dark Navy
                      Color(0xFF1E1B4B), // Midnight Violet
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4338CA).withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative ambient circles
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF818CF8).withValues(alpha: 0.1),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(AppTheme.s20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Quest Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.stars_rounded, size: 14, color: Color(0xFFFFD700)),
                                    SizedBox(width: 4),
                                    Text(
                                      'ACTIVE JOURNEY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                ),
                                child: const Text(
                                  '15 LEVELS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6EE7B7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Game Title & Subtitle
                          const Text(
                            'Colour Stroop',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStageName(highestUnlocked),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Level Progress Bar with Milestones
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Level $highestUnlocked of 15',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '$completedCount completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF818CF8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progress Bar with Gradient
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                FractionallySizedBox(
                                  widthFactor: (completedCount / 15).clamp(0.02, 1.0),
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.goldGradient,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFB800).withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Status text: last session
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                lastSession != null
                                    ? 'Last score: ${lastSession.score}/100 • ${_formatElapsedTime(lastSession.createdAt)}'
                                    : 'Start level 1 to establish your focus baseline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Play Level Button
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF312E81),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GameIntroScreen(level: highestUnlocked),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, size: 24),
                                  const SizedBox(width: 6),
                                  Text('Play Level $highestUnlocked'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // View Journey Map Secondary Button
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelTreeScreen(),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.alt_route_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'View Level Journey Map',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              // 3 Quick Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      icon: Icons.flag_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Current',
                      value: 'Lv $highestUnlocked',
                      subtitle: 'of 15',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Best Score',
                      value: '$bestScore',
                      subtitle: 'points',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      context: context,
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Done',
                      value: '$completedCount',
                      subtitle: 'levels',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.s32),

              // SECTION: Cognitive Suite ("MORE GAMES")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'COGNITIVE EXPANSION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GamesLibraryScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceAlt,
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SEE SUITE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: accent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s16),

              // 2x2 Interactive Preview Game Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppTheme.s12,
                crossAxisSpacing: AppTheme.s12,
                childAspectRatio: 1.18,
                children: [
                  _buildSuiteCard(
                    context: context,
                    title: 'Memory Matrix',
                    domain: 'Working Memory',
                    icon: Icons.grid_view_rounded,
                    gradient: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
                    isDark: isDark,
                    badgeText: 'PLAY • Lv $matrixHighestUnlocked',
                    badgeColor: const Color(0xFF06B6D4).withValues(alpha: 0.18),
                    badgeTextColor: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatrixIntroScreen(level: matrixHighestUnlocked),
                        ),
                      );
                    },
                  ),
                  _buildSuiteCard(
                    context: context,
                    title: 'Focus Radar',
                    domain: 'Selective Attention',
                    icon: Icons.radar_rounded,
                    gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                    isDark: isDark,
                    badgeText: 'PLAY • Lv $radarHighestUnlocked',
                    badgeColor: const Color(0xFF10B981).withValues(alpha: 0.18),
                    badgeTextColor: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RadarIntroScreen(level: radarHighestUnlocked),
                        ),
                      );
                    },
                  ),
                  _buildSuiteCard(
                    context: context,
                    title: 'Speed Tap',
                    domain: 'Processing Speed',
                    icon: Icons.electric_bolt_rounded,
                    gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                    isDark: isDark,
                    badgeText: 'PLAY • Lv $speedTapHighestUnlocked',
                    badgeColor: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                    badgeTextColor: isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpeedTapIntroScreen(level: speedTapHighestUnlocked),
                        ),
                      );
                    },
                  ),
                  _buildSuiteCard(
                    context: context,
                    title: 'Logic Flow',
                    domain: 'Fluid Reasoning',
                    icon: Icons.psychology_rounded,
                    gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    isDark: isDark,
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.s32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: isDark ? null : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuiteCard({
    required BuildContext context,
    required String title,
    required String domain,
    required IconData icon,
    required List<Color> gradient,
    required bool isDark,
    String badgeText = 'SOON',
    Color? badgeColor,
    Color? badgeTextColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: onTap != null
                ? gradient.first.withValues(alpha: 0.5)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: onTap != null ? 1.5 : 1.0,
          ),
          boxShadow: isDark ? null : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor ?? (isDark
                        ? AppColors.darkSurfaceAlt
                        : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: badgeTextColor ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  domain,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
