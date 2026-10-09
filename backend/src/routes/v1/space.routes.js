/**
 * @file space.routes.js
 * @description Express routes for Space CRUD endpoints.
 */

import { Router } from "express";
import {
  getSpaces,
  getSpaceById,
  createSpace,
  updateSpace,
  deleteSpace,
} from "../../controllers/space.controller.js";
import { validate } from "../../middleware/validate.js";
import { createSpaceSchema, updateSpaceSchema } from "../../validators/space.validator.js";

const router = Router();

// GET /api/v1/spaces - Get paginated spaces
router.get("/", getSpaces);

// GET /api/v1/spaces/:id - Get space by ID
router.get("/:id", getSpaceById);

// POST /api/v1/spaces - Create space
router.post("/", validate(createSpaceSchema), createSpace);

// PUT /api/v1/spaces/:id - Update space
router.put("/:id", validate(updateSpaceSchema), updateSpace);

// DELETE /api/v1/spaces/:id - Delete space
router.delete("/:id", deleteSpace);

export default router;
