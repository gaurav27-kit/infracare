/**
 * @file floor.controller.js
 * @description HTTP Controller handling requests for Floor entities.
 */

import floorService from "../services/floor.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/floors
 * @desc    Get paginated active floor entities
 * @access  Public / Authenticated
 */
export const getFloors = asyncHandler(async (req, res) => {
  const { data, meta } = await floorService.getAllFloors(req.query);
  return ApiResponse.success(res, "Floors retrieved successfully", data, 200, meta);
});

/**
 * @route   GET /api/v1/floors/:id
 * @desc    Get floor details by ID
 * @access  Public / Authenticated
 */
export const getFloorById = asyncHandler(async (req, res) => {
  const floor = await floorService.getFloorById(req.params.id);
  return ApiResponse.success(res, "Floor details retrieved successfully", floor);
});

/**
 * @route   POST /api/v1/floors
 * @desc    Create a new floor under a building
 * @access  Admin
 */
export const createFloor = asyncHandler(async (req, res) => {
  const newFloor = await floorService.createFloor(req.body);
  return ApiResponse.success(res, "Floor created successfully", newFloor, 201);
});

/**
 * @route   PUT /api/v1/floors/:id
 * @desc    Update floor details by ID
 * @access  Admin
 */
export const updateFloor = asyncHandler(async (req, res) => {
  const updatedFloor = await floorService.updateFloor(req.params.id, req.body);
  return ApiResponse.success(res, "Floor updated successfully", updatedFloor);
});

/**
 * @route   DELETE /api/v1/floors/:id
 * @desc    Soft-delete floor by ID (if no spaces exist)
 * @access  Admin
 */
export const deleteFloor = asyncHandler(async (req, res) => {
  const result = await floorService.deleteFloor(req.params.id);
  return ApiResponse.success(res, "Floor deleted successfully", result);
});
