import 'package:flutter/foundation.dart' show kIsWeb;

/// Base URL and endpoint path constants for the InfraCare REST API.
class ApiConstants {
  ApiConstants._();

  // ---------------------------------------------------------------------------
  // Base URL (Configurable via --dart-define=API_BASE_URL=https://your-api.com/api/v1)
  // ---------------------------------------------------------------------------
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb
        ? 'http://127.0.0.1:5000/api/v1'
        : 'http://10.0.2.2:5000/api/v1',
  );

  // ---------------------------------------------------------------------------
  // Connection / Timeout
  // ---------------------------------------------------------------------------
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;

  // ---------------------------------------------------------------------------
  // Auth Headers
  // ---------------------------------------------------------------------------
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';

  // ---------------------------------------------------------------------------
  // Endpoints
  // ---------------------------------------------------------------------------

  // Issues
  static const String issues = '/issues';
  static String issueDetail(String id) => '/issues/$id';
  static String issueAttachments(String issueId) => '/issues/$issueId/attachments';
  static String attachmentDetail(String id) => '/attachments/$id';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardIssueStats = '/dashboard/issues';
  static const String dashboardRecentIssues = '/dashboard/recent-issues';

  // Master Data
  static const String masterBuildings = '/buildings';
  static const String masterFloors = '/floors';
  static const String masterSpaces = '/spaces';
  static const String masterAssets = '/assets';
}
