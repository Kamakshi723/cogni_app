import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textPrimary),
        title: Text(
          'Privacy policy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cogni Privacy Policy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.s8),
              Text(
                'Last updated: October 2026',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: AppTheme.s16),
              CogniCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information We Collect',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.s8),
                    Text(
                      '1. Account Information: If you create an account, we store your name and email address to sync sessions across devices.\n\n2. Gameplay Session Data: We record Stroop trial response timestamps, correctness, reaction times (in milliseconds), accuracy, and calculated level changes.\n\n3. Device Preferences: We save your sound, haptics, and colour-blind mode toggles locally.',
                      style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: AppTheme.s16),
                    Text(
                      'How Your Data is Used',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.s8),
                    Text(
                      'Your data is exclusively used to present your personal score history, plot your progress chart, and adapt difficulty levels to your play. We do NOT sell, rent, or monetize your personal or gameplay data with third-party advertisers or data brokers.',
                      style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: AppTheme.s16),
                    Text(
                      'Your Rights & Data Portability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.s8),
                    Text(
                      '• Export: You can export all your session data as a standard JSON file at any time under Settings → Data.\n• Delete: You can permanently wipe your account and all associated history under Settings → Delete my account.',
                      style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.s32),
            ],
          ),
        ),
      ),
    );
  }
}
