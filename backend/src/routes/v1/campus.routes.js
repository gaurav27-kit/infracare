/**
 * @file campus.routes.js
 * @description Express routes for single Campus configuration endpoints.
 */

import { Router } from "express";
import { getCampus, updateCampus } from "../../controllers/campus.controller.js";
import { validate } from "../../middleware/validate.js";
import { updateCampusSchema } from "../../validators/campus.validator.js";

const router = Router();

// GET /api/v1/campus - Get single campus details
router.get("/", getCampus);

// PUT /api/v1/campus - Update single campus details
router.put("/", validate(updateCampusSchema), updateCampus);

export default router;
