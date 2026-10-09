/**
 * @file workOrder.validator.js
 * @description Zod schema validation for WorkOrder request payloads.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";
import { WorkOrderPriority, WorkOrderStatus } from "../types/enums.js";

const W = VALIDATION_LIMITS.WORK_ORDER;

export const createWorkOrderSchema = z.object({
  issueId: z.string({ required_error: "Issue ID is required" }).uuid("Invalid Issue ID format"),
  maintenanceDepartmentId: z
    .string({ required_error: "Maintenance Department ID is required" })
    .uuid("Invalid Maintenance Department ID format"),
  assignedToExternalUserId: z.string().trim().optional(),
  priority: z.nativeEnum(WorkOrderPriority, { invalid_type_error: "Invalid WorkOrderPriority" }).optional(),
  status: z.nativeEnum(WorkOrderStatus, { invalid_type_error: "Invalid WorkOrderStatus" }).optional(),
  scheduledStart: z.string().datetime({ message: "Invalid scheduledStart date format" }).optional(),
  scheduledEnd: z.string().datetime({ message: "Invalid scheduledEnd date format" }).optional(),
  actualStart: z.string().datetime({ message: "Invalid actualStart date format" }).optional(),
  actualEnd: z.string().datetime({ message: "Invalid actualEnd date format" }).optional(),
  cost: z
    .number()
    .min(W.COST_MIN, `Cost cannot be negative`)
    .max(W.COST_MAX, `Cost cannot exceed ${W.COST_MAX}`)
    .optional(),
  resolutionNotes: z
    .string()
    .trim()
    .max(W.RESOLUTION_NOTES_MAX, `Resolution notes cannot exceed ${W.RESOLUTION_NOTES_MAX} characters`)
    .optional(),
});

export const updateWorkOrderSchema = z.object({
  issueId: z.string().uuid("Invalid Issue ID format").optional(),
  maintenanceDepartmentId: z.string().uuid("Invalid Maintenance Department ID format").optional(),
  assignedToExternalUserId: z.string().trim().optional(),
  priority: z.nativeEnum(WorkOrderPriority, { invalid_type_error: "Invalid WorkOrderPriority" }).optional(),
  status: z.nativeEnum(WorkOrderStatus, { invalid_type_error: "Invalid WorkOrderStatus" }).optional(),
  scheduledStart: z.string().datetime({ message: "Invalid scheduledStart date format" }).optional().nullable(),
  scheduledEnd: z.string().datetime({ message: "Invalid scheduledEnd date format" }).optional().nullable(),
  actualStart: z.string().datetime({ message: "Invalid actualStart date format" }).optional().nullable(),
  actualEnd: z.string().datetime({ message: "Invalid actualEnd date format" }).optional().nullable(),
  cost: z
    .number()
    .min(W.COST_MIN, `Cost cannot be negative`)
    .max(W.COST_MAX, `Cost cannot exceed ${W.COST_MAX}`)
    .optional()
    .nullable(),
  resolutionNotes: z
    .string()
    .trim()
    .max(W.RESOLUTION_NOTES_MAX, `Resolution notes cannot exceed ${W.RESOLUTION_NOTES_MAX} characters`)
    .optional()
    .nullable(),
});
