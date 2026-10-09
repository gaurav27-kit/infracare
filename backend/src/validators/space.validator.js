/**
 * @file space.validator.js
 * @description Zod schema validation for Space request payloads using Master Data Foundation limits.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";
import { SpaceType } from "../types/enums.js";

const S = VALIDATION_LIMITS.SPACE;

export const createSpaceSchema = z.object({
  floorId: z.string({ required_error: "Floor ID is required" }).uuid("Invalid Floor ID format"),
  name: z
    .string({ required_error: "Space name is required" })
    .trim()
    .min(S.NAME_MIN, `Space name must be at least ${S.NAME_MIN} characters`)
    .max(S.NAME_MAX, `Space name cannot exceed ${S.NAME_MAX} characters`),
  code: z
    .string({ required_error: "Space code is required" })
    .trim()
    .min(S.CODE_MIN, `Space code must be at least ${S.CODE_MIN} characters`)
    .max(S.CODE_MAX, `Space code cannot exceed ${S.CODE_MAX} characters`)
    .toUpperCase(),
  type: z.nativeEnum(SpaceType, { required_error: "Space type is required", invalid_type_error: "Invalid SpaceType" }),
  capacity: z.coerce
    .number()
    .int("Capacity must be an integer")
    .min(S.CAPACITY_MIN, `Capacity cannot be negative`)
    .max(S.CAPACITY_MAX, `Capacity cannot exceed ${S.CAPACITY_MAX}`)
    .nullable()
    .optional(),
  isAccessible: z.boolean().optional(),
  isActive: z.boolean().optional(),
});

export const updateSpaceSchema = z.object({
  floorId: z.string().uuid("Invalid Floor ID format").optional(),
  name: z
    .string()
    .trim()
    .min(S.NAME_MIN, `Space name must be at least ${S.NAME_MIN} characters`)
    .max(S.NAME_MAX, `Space name cannot exceed ${S.NAME_MAX} characters`)
    .optional(),
  code: z
    .string()
    .trim()
    .min(S.CODE_MIN, `Space code must be at least ${S.CODE_MIN} characters`)
    .max(S.CODE_MAX, `Space code cannot exceed ${S.CODE_MAX} characters`)
    .toUpperCase()
    .optional(),
  type: z.nativeEnum(SpaceType, { invalid_type_error: "Invalid SpaceType" }).optional(),
  capacity: z.coerce
    .number()
    .int("Capacity must be an integer")
    .min(S.CAPACITY_MIN, `Capacity cannot be negative`)
    .max(S.CAPACITY_MAX, `Capacity cannot exceed ${S.CAPACITY_MAX}`)
    .nullable()
    .optional(),
  isAccessible: z.boolean().optional(),
  isActive: z.boolean().optional(),
});
