/**
 * @file space.controller.js
 * @description HTTP Controller handling requests for Space entities.
 */

import spaceService from "../services/space.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/spaces
 * @desc    Get paginated active space entities
 * @access  Public / Authenticated
 */
export const getSpaces = asyncHandler(async (req, res) => {
  const { data, meta } = await spaceService.getAllSpaces(req.query);
  return ApiResponse.success(res, "Spaces retrieved successfully", data, 200, meta);
});

/**
 * @route   GET /api/v1/spaces/:id
 * @desc    Get space details by ID
 * @access  Public / Authenticated
 */
export const getSpaceById = asyncHandler(async (req, res) => {
  const space = await spaceService.getSpaceById(req.params.id);
  return ApiResponse.success(res, "Space details retrieved successfully", space);
});

/**
 * @route   POST /api/v1/spaces
 * @desc    Create a new space entity
 * @access  Admin
 */
export const createSpace = asyncHandler(async (req, res) => {
  const newSpace = await spaceService.createSpace(req.body);
  return ApiResponse.success(res, "Space created successfully", newSpace, 201);
});

/**
 * @route   PUT /api/v1/spaces/:id
 * @desc    Update space details by ID
 * @access  Admin
 */
export const updateSpace = asyncHandler(async (req, res) => {
  const updatedSpace = await spaceService.updateSpace(req.params.id, req.body);
  return ApiResponse.success(res, "Space updated successfully", updatedSpace);
});

/**
 * @route   DELETE /api/v1/spaces/:id
 * @desc    Soft-delete space by ID (if no assets exist)
 * @access  Admin
 */
export const deleteSpace = asyncHandler(async (req, res) => {
  const result = await spaceService.deleteSpace(req.params.id);
  return ApiResponse.success(res, "Space deleted successfully", result);
});
