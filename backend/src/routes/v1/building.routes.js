/**
 * @file building.routes.js
 * @description Express routes for Building CRUD endpoints.
 */

import { Router } from "express";
import {
  getBuildings,
  getBuildingById,
  createBuilding,
  updateBuilding,
  deleteBuilding,
} from "../../controllers/building.controller.js";
import { validate } from "../../middleware/validate.js";
import { createBuildingSchema, updateBuildingSchema } from "../../validators/building.validator.js";

const router = Router();

// GET /api/v1/buildings - Get all active buildings
router.get("/", getBuildings);

// GET /api/v1/buildings/:id - Get building by ID
router.get("/:id", getBuildingById);

// POST /api/v1/buildings - Create building
router.post("/", validate(createBuildingSchema), createBuilding);

// PUT /api/v1/buildings/:id - Update building
router.put("/:id", validate(updateBuildingSchema), updateBuilding);

// DELETE /api/v1/buildings/:id - Delete building
router.delete("/:id", deleteBuilding);

export default router;
