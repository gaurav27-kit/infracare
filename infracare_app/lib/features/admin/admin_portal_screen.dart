import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'admin_dashboard_screen.dart';
import 'issues/admin_issue_details_screen.dart';
import 'issues/issues_management_screen.dart';
import 'reports/reports_analytics_screen.dart';
import 'settings/admin_settings_screen.dart';

/// Root screen for the InfraCare Admin Portal.
///
/// Features:
///  • Bottom Navigation with 4 primary tabs: Dashboard, Issues, Reports, Settings
///  • Inline navigation to [AdminIssueDetailsScreen] to preserve tab state
///  • Strict Role-Based Protection ensuring only [UserRole.admin] can access
class AdminPortalScreen extends ConsumerStatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  ConsumerState<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends ConsumerState<AdminPortalScreen> {
  int _currentIndex = 0;
  String? _selectedIssueId;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _selectedIssueId = null;
    });
  }

  void _openIssueDetails(String issueId) {
    setState(() {
      _selectedIssueId = issueId;
    });
  }

  void _closeIssueDetails() {
    setState(() {
      _selectedIssueId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Role protection: Redirect if not authenticated as Admin
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
      );
    }

    if (user.role != UserRole.admin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainNav);
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
      );
    }

    // Inline Detail Screen Display
    if (_selectedIssueId != null) {
      return AdminIssueDetailsScreen(
        issueId: _selectedIssueId!,
        onBack: _closeIssueDetails,
      );
    }

    final List<Widget> screens = [
      AdminDashboardScreen(
        onNavigateToTab: _onTabSelected,
        onSelectIssue: _openIssueDetails,
      ),
      IssuesManagementScreen(
        onNavigateToTab: _onTabSelected,
        onSelectIssue: _openIssueDetails,
      ),
      ReportsAnalyticsScreen(
        onNavigateToTab: _onTabSelected,
      ),
      const AdminSettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            activeIcon: Icon(Icons.warning_rounded),
            label: 'Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
