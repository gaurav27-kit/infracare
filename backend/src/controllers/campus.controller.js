/**
 * @file campus.controller.js
 * @description HTTP Controller handling requests for single Campus configuration.
 */

import campusService from "../services/campus.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/campus
 * @desc    Get details of the single campus entity
 * @access  Public / Authenticated
 */
export const getCampus = asyncHandler(async (req, res) => {
  const campus = await campusService.getCampus();
  return ApiResponse.success(res, "Campus details retrieved successfully", campus);
});

/**
 * @route   PUT /api/v1/campus
 * @desc    Update details of the single campus entity
 * @access  Admin
 */
export const updateCampus = asyncHandler(async (req, res) => {
  const updatedCampus = await campusService.updateCampus(req.body);
  return ApiResponse.success(res, "Campus details updated successfully", updatedCampus);
});
