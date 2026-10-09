import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/issue_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;
  final Function(String)? onSelectIssue;

  const DashboardScreen({
    Key? key,
    this.onNavigateToTab,
    this.onSelectIssue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.domain_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'InfraCare',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              child: const Icon(Icons.person, size: 18, color: AppColors.textPrimary),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            const Text(
              'Good Morning, Alex 👋',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here's your infrastructure overview for today.",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Report Issue', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: () {
                      if (onNavigateToTab != null) onNavigateToTab!(1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.format_list_bulleted, size: 20, color: AppColors.textPrimary),
                    label: const Text('My Issues', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      if (onNavigateToTab != null) onNavigateToTab!(2);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics Grid (Open, In Progress, Resolved, Critical)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  title: 'Open Issues',
                  count: '12',
                  icon: Icons.assignment_outlined,
                  color: AppColors.primary,
                ),
                _buildStatCard(
                  title: 'In Progress',
                  count: '5',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.warning,
                ),
                _buildStatCard(
                  title: 'Resolved',
                  count: '48',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                ),
                _buildStatCard(
                  title: 'Critical',
                  count: '2',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  isAlert: true,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Recent Issues Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Issues',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (onNavigateToTab != null) onNavigateToTab!(2);
                  },
                  child: const Row(
                    children: [
                      Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Issues List
            IssueCard(
              issueId: '#IC-204',
              title: 'Broken AC Unit in Library 2nd Floor',
              location: 'Main Library, 2nd Floor HVAC Sector',
              date: '2h ago',
              status: 'In Progress',
              priority: 'High',
              onTap: () {
                if (onSelectIssue != null) onSelectIssue!('#IC-204');
              },
            ),
            IssueCard(
              issueId: '#IC-203',
              title: 'Network Switch Outage in Engineering',
              location: 'Engineering Bldg A, Server Room',
              date: '4h ago',
              status: 'Open',
              priority: 'Critical',
              onTap: () {
                if (onSelectIssue != null) onSelectIssue!('#IC-203');
              },
            ),
            IssueCard(
              issueId: '#IC-202',
              title: 'Water Pipe Leakage near Cafeteria',
              location: 'Science Hall Block B, Basement',
              date: '1d ago',
              status: 'Resolved',
              priority: 'Low',
              onTap: () {
                if (onSelectIssue != null) onSelectIssue!('#IC-202');
              },
            ),
            const SizedBox(height: 24),

            // System Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.show_chart_rounded, color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM OPERATIONAL',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All campus power & water lines operating at 99.4%',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppColors.danger.withOpacity(0.5) : AppColors.cardBorder,
          width: isAlert ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isAlert ? AppColors.danger : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              color: isAlert ? AppColors.danger : AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
