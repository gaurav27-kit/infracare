import 'package:flutter/material.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/report_issue/report_issue_screen.dart';
import '../features/issues/my_issues_screen.dart';
import '../features/issue_details/issue_details_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/main_navigation_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String mainNav = '/';
  static const String dashboard = '/dashboard';
  static const String reportIssue = '/report-issue';
  static const String myIssues = '/my-issues';
  static const String issueDetails = '/issue-details';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        mainNav: (context) => const MainNavigationScreen(),
        dashboard: (context) => const DashboardScreen(),
        reportIssue: (context) => const ReportIssueScreen(),
        myIssues: (context) => const MyIssuesScreen(),
        issueDetails: (context) => const IssueDetailsScreen(),
        settings: (context) => const SettingsScreen(),
      };
}
