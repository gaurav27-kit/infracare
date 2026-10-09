/**
 * @file dashboard.routes.js
 * @description Express routes for read-only Dashboard endpoints.
 */

import { Router } from "express";
import {
  getSummary,
  getIssueStatistics,
  getAssetStatistics,
  getMaintenanceOverview,
  getRecentIssues,
  getRecentWorkOrders,
} from "../../controllers/dashboard.controller.js";

const router = Router();

// GET /api/v1/dashboard/summary
router.get("/summary", getSummary);

// GET /api/v1/dashboard/issues
router.get("/issues", getIssueStatistics);

// GET /api/v1/dashboard/assets
router.get("/assets", getAssetStatistics);

// GET /api/v1/dashboard/maintenance
router.get("/maintenance", getMaintenanceOverview);

// GET /api/v1/dashboard/recent-issues
router.get("/recent-issues", getRecentIssues);

// GET /api/v1/dashboard/recent-work-orders
router.get("/recent-work-orders", getRecentWorkOrders);

export default router;
