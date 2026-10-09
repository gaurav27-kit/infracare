import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/admin/admin_portal_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/report_issue/report_issue_screen.dart';
import '../features/issues/my_issues_screen.dart';
import '../features/issue_details/issue_details_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/main_navigation_screen.dart';

/// Named route registry for the InfraCare application.
///
/// All navigation should go through named routes to keep
/// deep-linking and future push-notification routing straightforward.
class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Route names
  // ---------------------------------------------------------------------------
  static const String login = '/login';
  static const String mainNav = '/';
  static const String adminPortal = '/admin';
  static const String dashboard = '/dashboard';
  static const String reportIssue = '/report-issue';
  static const String myIssues = '/my-issues';
  static const String issueDetails = '/issue-details';
  static const String settings = '/settings';

  // ---------------------------------------------------------------------------
  // Route map
  // ---------------------------------------------------------------------------
  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        mainNav: (_) => const MainNavigationScreen(),
        adminPortal: (_) => const AdminPortalScreen(),
        dashboard: (_) => const DashboardScreen(),
        reportIssue: (_) => const ReportIssueScreen(),
        myIssues: (_) => const MyIssuesScreen(),
        issueDetails: (_) => const IssueDetailsScreen(),
        settings: (_) => const SettingsScreen(),
      };
}
