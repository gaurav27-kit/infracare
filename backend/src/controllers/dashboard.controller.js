/**
 * @file dashboard.controller.js
 * @description HTTP Controller handling requests for read-only Dashboard endpoints.
 */

import dashboardService from "../services/dashboard.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/dashboard/summary
 * @desc    Get campus summary and active entity counts
 * @access  Public / Authenticated
 */
export const getSummary = asyncHandler(async (req, res) => {
  const data = await dashboardService.getSummary();
  return ApiResponse.success(res, "Dashboard summary retrieved successfully", data);
});

/**
 * @route   GET /api/v1/dashboard/issues
 * @desc    Get issue statistics grouped by status and priority
 * @access  Public / Authenticated
 */
export const getIssueStatistics = asyncHandler(async (req, res) => {
  const data = await dashboardService.getIssueStatistics();
  return ApiResponse.success(res, "Issue statistics retrieved successfully", data);
});

/**
 * @route   GET /api/v1/dashboard/assets
 * @desc    Get asset statistics grouped by status
 * @access  Public / Authenticated
 */
export const getAssetStatistics = asyncHandler(async (req, res) => {
  const data = await dashboardService.getAssetStatistics();
  return ApiResponse.success(res, "Asset statistics retrieved successfully", data);
});

/**
 * @route   GET /api/v1/dashboard/maintenance
 * @desc    Get maintenance overview counts
 * @access  Public / Authenticated
 */
export const getMaintenanceOverview = asyncHandler(async (req, res) => {
  const data = await dashboardService.getMaintenanceOverview();
  return ApiResponse.success(res, "Maintenance overview retrieved successfully", data);
});

/**
 * @route   GET /api/v1/dashboard/recent-issues
 * @desc    Get top 5 recent active issues
 * @access  Public / Authenticated
 */
export const getRecentIssues = asyncHandler(async (req, res) => {
  const data = await dashboardService.getRecentIssues();
  return ApiResponse.success(res, "Recent issues retrieved successfully", data);
});

/**
 * @route   GET /api/v1/dashboard/recent-work-orders
 * @desc    Get top 5 recent active work orders
 * @access  Public / Authenticated
 */
export const getRecentWorkOrders = asyncHandler(async (req, res) => {
  const data = await dashboardService.getRecentWorkOrders();
  return ApiResponse.success(res, "Recent work orders retrieved successfully", data);
});
