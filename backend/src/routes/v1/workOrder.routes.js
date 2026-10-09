/**
 * @file workOrder.routes.js
 * @description Express routes for WorkOrder CRUD endpoints.
 */

import { Router } from "express";
import {
  getWorkOrders,
  getWorkOrderById,
  createWorkOrder,
  updateWorkOrder,
  deleteWorkOrder,
} from "../../controllers/workOrder.controller.js";
import { validate } from "../../middleware/validate.js";
import { createWorkOrderSchema, updateWorkOrderSchema } from "../../validators/workOrder.validator.js";

const router = Router();

// GET /api/v1/work-orders - Get paginated work orders
router.get("/", getWorkOrders);

// GET /api/v1/work-orders/:id - Get work order by ID
router.get("/:id", getWorkOrderById);

// POST /api/v1/work-orders - Create work order
router.post("/", validate(createWorkOrderSchema), createWorkOrder);

// PUT /api/v1/work-orders/:id - Update work order
router.put("/:id", validate(updateWorkOrderSchema), updateWorkOrder);

// DELETE /api/v1/work-orders/:id - Delete work order
router.delete("/:id", deleteWorkOrder);

export default router;
