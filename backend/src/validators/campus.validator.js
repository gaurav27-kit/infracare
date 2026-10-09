/**
 * @file campus.validator.js
 * @description Zod schema validation for Campus request payloads using Master Data Foundation limits.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";

const C = VALIDATION_LIMITS.CAMPUS;

export const updateCampusSchema = z.object({
  name: z
    .string()
    .trim()
    .min(C.NAME_MIN, `Campus name must be at least ${C.NAME_MIN} characters`)
    .max(C.NAME_MAX, `Campus name cannot exceed ${C.NAME_MAX} characters`)
    .optional(),
  code: z
    .string()
    .trim()
    .min(C.CODE_MIN, `Campus code must be at least ${C.CODE_MIN} characters`)
    .max(C.CODE_MAX, `Campus code cannot exceed ${C.CODE_MAX} characters`)
    .toUpperCase()
    .optional(),
  description: z.string().trim().nullable().optional(),
  address: z.string().trim().nullable().optional(),
  phone: z
    .string()
    .trim()
    .max(C.PHONE_MAX, `Phone number cannot exceed ${C.PHONE_MAX} characters`)
    .nullable()
    .optional(),
  email: z
    .string()
    .trim()
    .email("Invalid email address format")
    .max(C.EMAIL_MAX, `Email address cannot exceed ${C.EMAIL_MAX} characters`)
    .nullable()
    .optional(),
  website: z.string().trim().url("Invalid website URL format").nullable().optional().or(z.literal("")),
  logoUrl: z.string().trim().url("Invalid logo URL format").nullable().optional().or(z.literal("")),
});
