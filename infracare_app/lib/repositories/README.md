// This directory is reserved for repository classes that will be
// implemented during backend API integration.
//
// Planned repositories:
//   - IssueRepository    → CRUD operations for issues
//   - DashboardRepository → dashboard stats and recent issues
//   - MasterDataRepository → campuses, buildings, floors, spaces, assets
//   - AuthRepository      → login, refresh, logout
//   - MediaRepository     → photo/video upload
//
// Each repository will:
//   1. Use ApiClient to make HTTP requests
//   2. Parse responses into model classes
//   3. Return ApiResponse<T> to the caller
//
// Do NOT add implementation logic here until the backend is ready.
