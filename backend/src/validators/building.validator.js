/**
 * @file building.validator.js
 * @description Zod schema validation for Building request payloads using Master Data Foundation limits.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";

const B = VALIDATION_LIMITS.BUILDING;

export const createBuildingSchema = z.object({
  name: z
    .string({ required_error: "Building name is required" })
    .trim()
    .min(B.NAME_MIN, `Building name must be at least ${B.NAME_MIN} characters`)
    .max(B.NAME_MAX, `Building name cannot exceed ${B.NAME_MAX} characters`),
  code: z
    .string({ required_error: "Building code is required" })
    .trim()
    .min(B.CODE_MIN, `Building code must be at least ${B.CODE_MIN} characters`)
    .max(B.CODE_MAX, `Building code cannot exceed ${B.CODE_MAX} characters`)
    .toUpperCase(),
});

export const updateBuildingSchema = z.object({
  name: z
    .string()
    .trim()
    .min(B.NAME_MIN, `Building name must be at least ${B.NAME_MIN} characters`)
    .max(B.NAME_MAX, `Building name cannot exceed ${B.NAME_MAX} characters`)
    .optional(),
  code: z
    .string()
    .trim()
    .min(B.CODE_MIN, `Building code must be at least ${B.CODE_MIN} characters`)
    .max(B.CODE_MAX, `Building code cannot exceed ${B.CODE_MAX} characters`)
    .toUpperCase()
    .optional(),
});
