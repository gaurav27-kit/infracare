import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_bottom_sheet.dart';
import '../../widgets/custom_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showAboutDialog(BuildContext context) {
    CustomDialog.show(
      context: context,
      title: 'About InfraCare',
      message: 'InfraCare is an AI-powered campus infrastructure monitoring & maintenance tracking platform developed as a final year engineering capstone project.',
      primaryButtonText: 'Close',
      secondaryButtonText: null,
      icon: Icons.domain,
      iconColor: AppColors.primary,
      onPrimaryPressed: () {},
    );
  }

  void _showHelpSheet(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      title: 'Help & FAQ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFaqItem('How do I submit an infrastructure issue?', 'Navigate to the "Report" tab, select your campus location, describe the issue, attach photos, and click Submit.'),
          const SizedBox(height: 12),
          _buildFaqItem('Who receives my reported issues?', 'Reports are automatically routed to campus facilities management and technicians based on location and priority.'),
          const SizedBox(height: 12),
          _buildFaqItem('What qualifies as a Critical issue?', 'Power outages, major pipe bursts, elevator trapped passengers, or hazardous structural failures.'),
        ],
      ),
    );
  }

  void _showPrivacyPolicySheet(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      title: 'Privacy Policy',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Protection & Privacy Policy',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'InfraCare collects location telemetry and reported fault details strictly for facility management, campus maintenance dispatching, and infrastructure safety auditing. No personal user data is shared with third parties.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showTermsSheet(BuildContext context) {
    CustomBottomSheet.show(
      context: context,
      title: 'Terms & Conditions',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'InfraCare Terms of Service',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'By using InfraCare, campus staff and students agree to submit authentic, accurate maintenance reports. Misuse or fake emergency reporting may lead to account suspension.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(answer, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.domain_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          AppConstants.appTagline,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            AppConstants.appVersion,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'APPLICATION INFO',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'About InfraCare',
                    subtitle: 'Final year engineering project overview',
                    onTap: () => _showAboutDialog(context),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & FAQ',
                    subtitle: 'Guides, FAQs, and support details',
                    onTap: () => _showHelpSheet(context),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Data handling and security guidelines',
                    onTap: () => _showPrivacyPolicySheet(context),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Legal agreements and usage terms',
                    onTap: () => _showTermsSheet(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'PREFERENCES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: true,
                    onChanged: (val) {},
                    activeColor: AppColors.primary,
                    title: const Text('Dark Mode Theme', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Always enabled (Material 3 Dark)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.textSecondary),
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  ListTile(
                    leading: const Icon(Icons.api, color: AppColors.textSecondary),
                    title: const Text('REST API Environment', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Backend REST endpoints connected', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Center(
              child: Text(
                'InfraCare Capstone Project © 2026',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
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
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
