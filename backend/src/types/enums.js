/**
 * @file enums.js
 * @description Centralized application enums mirroring Prisma schema definitions.
 */

export const SpaceType = Object.freeze({
  CLASSROOM: "CLASSROOM",
  LABORATORY: "LABORATORY",
  OFFICE: "OFFICE",
  LIBRARY: "LIBRARY",
  SEMINAR_HALL: "SEMINAR_HALL",
  WORKSHOP: "WORKSHOP",
  CORRIDOR: "CORRIDOR",
  STAIRCASE: "STAIRCASE",
  WASHROOM: "WASHROOM",
  CAFETERIA: "CAFETERIA",
  HOSTEL_ROOM: "HOSTEL_ROOM",
  STORE_ROOM: "STORE_ROOM",
  SERVER_ROOM: "SERVER_ROOM",
  ELECTRICAL_ROOM: "ELECTRICAL_ROOM",
  OTHER: "OTHER",
});

export const AssetStatus = Object.freeze({
  OPERATIONAL: "OPERATIONAL",
  FAULTY: "FAULTY",
  UNDER_MAINTENANCE: "UNDER_MAINTENANCE",
  DECOMMISSIONED: "DECOMMISSIONED",
});

export const IssuePriority = Object.freeze({
  LOW: "LOW",
  MEDIUM: "MEDIUM",
  HIGH: "HIGH",
  CRITICAL: "CRITICAL",
});

export const IssueStatus = Object.freeze({
  OPEN: "OPEN",
  ASSIGNED: "ASSIGNED",
  IN_PROGRESS: "IN_PROGRESS",
  RESOLVED: "RESOLVED",
  CLOSED: "CLOSED",
});

export const WorkOrderPriority = Object.freeze({
  LOW: "LOW",
  MEDIUM: "MEDIUM",
  HIGH: "HIGH",
  EMERGENCY: "EMERGENCY",
});

export const WorkOrderStatus = Object.freeze({
  SCHEDULED: "SCHEDULED",
  IN_PROGRESS: "IN_PROGRESS",
  ON_HOLD: "ON_HOLD",
  COMPLETED: "COMPLETED",
  CANCELLED: "CANCELLED",
});

export const MaintenanceType = Object.freeze({
  PREVENTIVE: "PREVENTIVE",
  CORRECTIVE: "CORRECTIVE",
  EMERGENCY: "EMERGENCY",
});
