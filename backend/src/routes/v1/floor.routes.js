/**
 * @file floor.routes.js
 * @description Express routes for Floor CRUD endpoints.
 */

import { Router } from "express";
import {
  getFloors,
  getFloorById,
  createFloor,
  updateFloor,
  deleteFloor,
} from "../../controllers/floor.controller.js";
import { validate } from "../../middleware/validate.js";
import { createFloorSchema, updateFloorSchema } from "../../validators/floor.validator.js";

const router = Router();

// GET /api/v1/floors - Get paginated floors
router.get("/", getFloors);

// GET /api/v1/floors/:id - Get floor by ID
router.get("/:id", getFloorById);

// POST /api/v1/floors - Create floor
router.post("/", validate(createFloorSchema), createFloor);

// PUT /api/v1/floors/:id - Update floor
router.put("/:id", validate(updateFloorSchema), updateFloor);

// DELETE /api/v1/floors/:id - Delete floor
router.delete("/:id", deleteFloor);

export default router;
