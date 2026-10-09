/**
 * @file floor.validator.js
 * @description Zod schema validation for Floor request payloads using Master Data Foundation limits.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";

const F = VALIDATION_LIMITS.FLOOR;

export const createFloorSchema = z.object({
  buildingId: z.string({ required_error: "Building ID is required" }).uuid("Invalid Building ID format"),
  name: z
    .string({ required_error: "Floor name is required" })
    .trim()
    .min(F.NAME_MIN, `Floor name must be at least ${F.NAME_MIN} character`)
    .max(F.NAME_MAX, `Floor name cannot exceed ${F.NAME_MAX} characters`),
  level: z.coerce
    .number({ required_error: "Floor level is required" })
    .int("Floor level must be an integer")
    .min(F.LEVEL_MIN, `Floor level cannot be below ${F.LEVEL_MIN}`)
    .max(F.LEVEL_MAX, `Floor level cannot exceed ${F.LEVEL_MAX}`),
  description: z.string().trim().nullable().optional(),
});

export const updateFloorSchema = z.object({
  buildingId: z.string().uuid("Invalid Building ID format").optional(),
  name: z
    .string()
    .trim()
    .min(F.NAME_MIN, `Floor name must be at least ${F.NAME_MIN} character`)
    .max(F.NAME_MAX, `Floor name cannot exceed ${F.NAME_MAX} characters`)
    .optional(),
  level: z.coerce
    .number()
    .int("Floor level must be an integer")
    .min(F.LEVEL_MIN, `Floor level cannot be below ${F.LEVEL_MIN}`)
    .max(F.LEVEL_MAX, `Floor level cannot exceed ${F.LEVEL_MAX}`)
    .optional(),
  description: z.string().trim().nullable().optional(),
});
