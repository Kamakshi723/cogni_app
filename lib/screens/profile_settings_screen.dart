import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/cogni_card.dart';
import 'auth_screen.dart';
import 'delete_account_screen.dart';
import 'disclaimer_screen.dart';
import 'how_to_play_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  void _showEditNameDialog(BuildContext context, AuthProvider auth) {
    final controller = TextEditingController(text: auth.user?.name ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                auth.updateName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Current password'),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'New password (at least 8 chars)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully.')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context) {
    final jsonStr = StorageService.exportAllData();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export my data'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final accentSoft = isDark ? AppColors.darkAccentSoft : AppColors.lightAccentSoft;

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final name = user?.name.isNotEmpty == true ? user!.name : 'Kashish';
    final email = user?.email.isNotEmpty == true ? user!.email : (user?.isGuest == true ? 'Guest session' : 'you@example.com');
    final level = user?.level ?? 1;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'K';

    final sessions = StorageService.getSessions();
    final blocksCount = sessions.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Me',
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
              // Profile Header Card
              CogniCard(
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lv $level · $blocksCount blocks',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              // ACCOUNT
              _buildSectionHeader('ACCOUNT', textSecondary),
              const SizedBox(height: AppTheme.s8),
              CogniCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      'Edit name',
                      onTap: () => _showEditNameDialog(context, auth),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      'Change password',
                      onTap: () => _showChangePasswordDialog(context),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      'Sign out',
                      onTap: () async {
                        await auth.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthScreen(initialIsLogin: true),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              // PLAY
              _buildSectionHeader('PLAY', textSecondary),
              const SizedBox(height: AppTheme.s8),
              CogniCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Sound',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                      ),
                      value: user?.soundEnabled ?? true,
                      activeThumbColor: accent,
                      onChanged: (val) {
                        auth.updatePreferences(sound: val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        'Haptics',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                      ),
                      value: user?.hapticsEnabled ?? true,
                      activeThumbColor: accent,
                      onChanged: (val) {
                        auth.updatePreferences(haptics: val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        'Colour-blind mode',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                      ),
                      subtitle: Text(
                        'Adds symbols (● ▲ ■ ★) to colour buttons',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      value: user?.colorBlindMode ?? false,
                      activeThumbColor: accent,
                      onChanged: (val) {
                        auth.updatePreferences(colorBlindMode: val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        'Offline mode simulation',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
                      ),
                      subtitle: Text(
                        'Test local offline storage and banners',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      value: auth.isOffline,
                      activeThumbColor: AppColors.feedbackMiss,
                      onChanged: (val) {
                        auth.toggleOfflineMode();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              // DATA
              _buildSectionHeader('DATA', textSecondary),
              const SizedBox(height: AppTheme.s8),
              CogniCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      'Export my data',
                      onTap: () => _showExportDataDialog(context),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      'Delete my account',
                      isDestructive: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountScreen(),
                          ),
                        );
                      },
                      textPrimary: AppColors.deleteRed,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.s24),

              // ABOUT
              _buildSectionHeader('ABOUT', textSecondary),
              const SizedBox(height: AppTheme.s8),
              CogniCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildListTile(
                      'How to play',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HowToPlayScreen(),
                          ),
                        );
                      },
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      'Disclaimer',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DisclaimerScreen(),
                          ),
                        );
                      },
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 1),
                    _buildListTile(
                      'Privacy policy',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Version',
                            style: TextStyle(
                              fontSize: 15,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            '1.0.0',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionHeader(String title, Color textSecondary) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textSecondary,
      ),
    );
  }

  Widget _buildListTile(
    String title, {
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
    bool isDestructive = false,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.deleteRed : textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: textSecondary,
      ),
      onTap: onTap,
    );
  }
}
