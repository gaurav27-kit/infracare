class AppConstants {
  AppConstants._();

  static const String appName = 'InfraCare';
  static const String appTagline = 'Campus Infrastructure Management';
  static const String appVersion = 'v1.0.0 (Build 2026.1)';

  // Dropdown Lists for Issue Reporting
  static const List<String> campuses = [
    'Main Campus',
    'North Engineering Campus',
    'South Innovation Hub',
    'West Medical Complex',
  ];

  static const List<String> buildings = [
    'Main Library & Resource Center',
    'Engineering Building Block A',
    'Science Hall Block B',
    'Campus Student Center',
    'Technology Labs Wing',
  ];

  static const List<String> floors = [
    'Basement Level B1',
    'Ground Floor',
    '1st Floor',
    '2nd Floor (HVAC Sector)',
    '3rd Floor',
  ];

  static const List<String> spaces = [
    'Server Room 204-B',
    'Utility Room 304',
    'Auditorium Main Hall',
    'Restroom Wing A',
    'Cafeteria Central',
  ];

  static const List<String> assets = [
    'HVAC Chiller Unit C-02',
    'Network Switch Rack 04',
    'Primary Water Pump P-1',
    'Elevator Shaft 2',
    'Main Circuit Breaker Panel',
  ];

  static const List<String> priorityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  static const List<String> issueStatuses = [
    'All',
    'Open',
    'In Progress',
    'Resolved',
    'Critical',
  ];
}
