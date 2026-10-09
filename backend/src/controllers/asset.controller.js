/**
 * @file asset.controller.js
 * @description HTTP Controller handling requests for Asset entities.
 */

import assetService from "../services/asset.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/assets
 * @desc    Get paginated active asset entities
 * @access  Public / Authenticated
 */
export const getAssets = asyncHandler(async (req, res) => {
  const { data, meta } = await assetService.getAllAssets(req.query);
  return ApiResponse.success(res, "Assets retrieved successfully", data, 200, meta);
});

/**
 * @route   GET /api/v1/assets/:id
 * @desc    Get asset details by ID
 * @access  Public / Authenticated
 */
export const getAssetById = asyncHandler(async (req, res) => {
  const asset = await assetService.getAssetById(req.params.id);
  return ApiResponse.success(res, "Asset details retrieved successfully", asset);
});

/**
 * @route   POST /api/v1/assets
 * @desc    Create a new asset entity
 * @access  Admin
 */
export const createAsset = asyncHandler(async (req, res) => {
  const newAsset = await assetService.createAsset(req.body);
  return ApiResponse.success(res, "Asset created successfully", newAsset, 201);
});

/**
 * @route   PUT /api/v1/assets/:id
 * @desc    Update asset details by ID
 * @access  Admin
 */
export const updateAsset = asyncHandler(async (req, res) => {
  const updatedAsset = await assetService.updateAsset(req.params.id, req.body);
  return ApiResponse.success(res, "Asset updated successfully", updatedAsset);
});

/**
 * @route   DELETE /api/v1/assets/:id
 * @desc    Soft-delete asset by ID
 * @access  Admin
 */
export const deleteAsset = asyncHandler(async (req, res) => {
  const result = await assetService.deleteAsset(req.params.id);
  return ApiResponse.success(res, "Asset deleted successfully", result);
});
