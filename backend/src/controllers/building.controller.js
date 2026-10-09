/**
 * @file building.controller.js
 * @description HTTP Controller handling requests for Building entities.
 */

import buildingService from "../services/building.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/buildings
 * @desc    Get all active building entities
 * @access  Public / Authenticated
 */
export const getBuildings = asyncHandler(async (req, res) => {
  const buildings = await buildingService.getAllBuildings();
  return ApiResponse.success(res, "Buildings retrieved successfully", buildings);
});

/**
 * @route   GET /api/v1/buildings/:id
 * @desc    Get building details by ID
 * @access  Public / Authenticated
 */
export const getBuildingById = asyncHandler(async (req, res) => {
  const building = await buildingService.getBuildingById(req.params.id);
  return ApiResponse.success(res, "Building details retrieved successfully", building);
});

/**
 * @route   POST /api/v1/buildings
 * @desc    Create a new building entity
 * @access  Admin
 */
export const createBuilding = asyncHandler(async (req, res) => {
  const newBuilding = await buildingService.createBuilding(req.body);
  return ApiResponse.success(res, "Building created successfully", newBuilding, 201);
});

/**
 * @route   PUT /api/v1/buildings/:id
 * @desc    Update building details by ID
 * @access  Admin
 */
export const updateBuilding = asyncHandler(async (req, res) => {
  const updatedBuilding = await buildingService.updateBuilding(req.params.id, req.body);
  return ApiResponse.success(res, "Building updated successfully", updatedBuilding);
});

/**
 * @route   DELETE /api/v1/buildings/:id
 * @desc    Soft-delete building by ID
 * @access  Admin
 */
export const deleteBuilding = asyncHandler(async (req, res) => {
  const result = await buildingService.deleteBuilding(req.params.id);
  return ApiResponse.success(res, "Building deleted successfully", result);
});
