import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'onboarding_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _canDelete = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(() {
      setState(() {
        _canDelete = _confirmController.text.trim() == 'DELETE';
      });
    });
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    if (!_canDelete) return;

    setState(() {
      _isDeleting = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.deleteAccount();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: textPrimary),
        title: Text(
          'Delete account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'This will permanently delete:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.s16),
              _buildBullet('Your account', textSecondary),
              const SizedBox(height: AppTheme.s8),
              _buildBullet('All your sessions', textSecondary),
              const SizedBox(height: AppTheme.s8),
              _buildBullet('Your progress history', textSecondary),
              const SizedBox(height: AppTheme.s24),

              Text(
                'This cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deleteRed,
                ),
              ),

              const SizedBox(height: AppTheme.s32),

              Text(
                'Type DELETE to confirm',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.s8),
              TextField(
                controller: _confirmController,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.s32),

              PrimaryButton(
                label: 'Delete my account',
                isDestructive: true,
                isLoading: _isDeleting,
                onPressed: _canDelete ? _handleDelete : null,
              ),
              const SizedBox(height: AppTheme.s16),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildBullet(String text, Color textSecondary) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: textSecondary,
          ),
        ),
        const SizedBox(width: AppTheme.s12),
        Text(
          text,
          style: TextStyle(fontSize: 15, color: textSecondary),
        ),
      ],
    );
  }
}
