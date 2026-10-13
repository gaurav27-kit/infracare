import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_routes.dart';

/// Admin Settings Screen matching Stitch Design.
class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  void _showAboutDialog(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: 'About InfraCare',
      message:
          'InfraCare is an enterprise campus infrastructure monitoring, '
          'incident management, and predictive maintenance platform.\n\n'
          'Admin Portal enables real-time facility oversight, status dispatches, '
          'and infrastructure diagnostics.',
      primaryButtonText: 'Close',
      secondaryButtonText: null,
      icon: Icons.admin_panel_settings,
      iconColor: AppColors.primaryLight,
      onPrimaryPressed: () {},
    );
  }

  void _showHelpSheet(BuildContext context) {
    CustomDialog.showContentDialog(
      context: context,
      title: 'Admin Help & FAQ',
      icon: Icons.help_outline,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFaqItem(
            'How do I change an issue status?',
            'Open the issue from Dashboard or Issues Management, review details, '
                'and tap "Update Status". The update syncs directly with the server.',
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            'How is priority assigned to issues?',
            'Issues reported as High or Critical take precedence in the dashboard '
                'overview and require immediate dispatch.',
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            'Do students see updated issue statuses in real time?',
            'Yes. Both Admin and Student Portals read from the same unified '
                'database repository.',
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicySheet(BuildContext context) {
    CustomDialog.showContentDialog(
      context: context,
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Protection & Privacy Policy',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'InfraCare collects location telemetry and reported fault details '
            'strictly for facility management, campus maintenance dispatching, '
            'and infrastructure safety auditing. No personal user data is '
            'shared with third parties.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsSheet(BuildContext context) {
    CustomDialog.showContentDialog(
      context: context,
      title: 'Terms & Conditions',
      icon: Icons.description_outlined,
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'InfraCare Terms of Service',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'By using InfraCare, administrative users agree to act diligently '
            'in reviewing and resolving reported infrastructure incidents. '
            'Administrative credentials must be safeguarded.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          answer,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Admin Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 2),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.primaryLight,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Campus Administrator',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'admin@infracare.com',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'SYSTEM ADMINISTRATOR',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Menu List
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About InfraCare',
                    subtitle: 'Platform overview and system version',
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & FAQ',
                    subtitle: 'Admin guidelines and dispatch instructions',
                    onTap: () => _showHelpSheet(context),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.policy_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Data governance and confidentiality',
                    onTap: () => _showPrivacyPolicySheet(context),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.gavel_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'System usage policies and responsibilities',
                    onTap: () => _showTermsSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Version & Logout Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_outlined, size: 18, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text(
                            'App Version',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppConstants.appVersion,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryLight, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
