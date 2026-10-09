/**
 * @file asset.routes.js
 * @description Express routes for Asset CRUD endpoints.
 */

import { Router } from "express";
import {
  getAssets,
  getAssetById,
  createAsset,
  updateAsset,
  deleteAsset,
} from "../../controllers/asset.controller.js";
import { validate } from "../../middleware/validate.js";
import { createAssetSchema, updateAssetSchema } from "../../validators/asset.validator.js";

const router = Router();

// GET /api/v1/assets - Get paginated assets
router.get("/", getAssets);

// GET /api/v1/assets/:id - Get asset by ID
router.get("/:id", getAssetById);

// POST /api/v1/assets - Create asset
router.post("/", validate(createAssetSchema), createAsset);

// PUT /api/v1/assets/:id - Update asset
router.put("/:id", validate(updateAssetSchema), updateAsset);

// DELETE /api/v1/assets/:id - Delete asset
router.delete("/:id", deleteAsset);

export default router;
