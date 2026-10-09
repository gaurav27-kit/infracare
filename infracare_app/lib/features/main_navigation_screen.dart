import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'report_issue/report_issue_screen.dart';
import 'issues/my_issues_screen.dart';
import 'issue_details/issue_details_screen.dart';
import 'settings/settings_screen.dart';

/// Root screen that owns the [BottomNavigationBar] and switches
/// between the four primary tabs using an [IndexedStack].
///
/// Also manages inline navigation to [IssueDetailsScreen] so that
/// going back from details returns the user to the same tab without
/// losing scroll position.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
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
    // Show issue details inline (no named route push) to preserve
    // the bottom nav bar back-navigation experience.
    if (_selectedIssueId != null) {
      return IssueDetailsScreen(
        issueId: _selectedIssueId!,
        onBack: _closeIssueDetails,
      );
    }

    final List<Widget> screens = [
      DashboardScreen(
        onNavigateToTab: _onTabSelected,
        onSelectIssue: _openIssueDetails,
      ),
      ReportIssueScreen(
        onSubmitSuccess: () => _onTabSelected(2),
      ),
      MyIssuesScreen(
        onSelectIssue: _openIssueDetails,
      ),
      const SettingsScreen(),
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
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_outlined),
            activeIcon: Icon(Icons.format_list_bulleted),
            label: 'My Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
