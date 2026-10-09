/**
 * @file issue.validator.js
 * @description Zod schema validation for Issue request payloads using Master Data Foundation limits.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";
import { IssuePriority, IssueStatus } from "../types/enums.js";

const I = VALIDATION_LIMITS.ISSUE;

export const createIssueSchema = z.object({
  spaceId: z.string({ required_error: "Space ID is required" }),
  assetId: z.string().nullable().optional(),
  customAssetName: z.string().trim().max(255).nullable().optional(),
  title: z
    .string({ required_error: "Issue title is required" })
    .trim()
    .min(I.TITLE_MIN, `Issue title must be at least ${I.TITLE_MIN} characters`)
    .max(I.TITLE_MAX, `Issue title cannot exceed ${I.TITLE_MAX} characters`),
  description: z
    .string({ required_error: "Issue description is required" })
    .trim()
    .min(I.DESCRIPTION_MIN, `Issue description must be at least ${I.DESCRIPTION_MIN} characters`)
    .max(I.DESCRIPTION_MAX, `Issue description cannot exceed ${I.DESCRIPTION_MAX} characters`),
  priority: z
    .string()
    .transform((val) => val.toUpperCase())
    .refine((val) => Object.values(IssuePriority).includes(val), {
      message: "Invalid IssuePriority",
    })
    .optional(),
  status: z
    .string()
    .transform((val) => val.toUpperCase().replace(/\s+/g, "_"))
    .refine((val) => Object.values(IssueStatus).includes(val), {
      message: "Invalid IssueStatus",
    })
    .optional(),
  reporterExternalUserId: z.string().trim().optional(),
  location: z.string().trim().optional(),
  attachments: z.array(z.any()).optional(),
});

export const updateIssueSchema = z.object({
  spaceId: z.string().optional(),
  assetId: z.string().nullable().optional(),
  customAssetName: z.string().trim().max(255).nullable().optional(),
  title: z
    .string()
    .trim()
    .min(I.TITLE_MIN, `Issue title must be at least ${I.TITLE_MIN} characters`)
    .max(I.TITLE_MAX, `Issue title cannot exceed ${I.TITLE_MAX} characters`)
    .optional(),
  description: z
    .string()
    .trim()
    .min(I.DESCRIPTION_MIN, `Issue description must be at least ${I.DESCRIPTION_MIN} characters`)
    .max(I.DESCRIPTION_MAX, `Issue description cannot exceed ${I.DESCRIPTION_MAX} characters`)
    .optional(),
  priority: z
    .string()
    .transform((val) => val.toUpperCase())
    .refine((val) => Object.values(IssuePriority).includes(val), {
      message: "Invalid IssuePriority",
    })
    .optional(),
  status: z
    .string()
    .transform((val) => val.toUpperCase().replace(/\s+/g, "_"))
    .refine((val) => Object.values(IssueStatus).includes(val), {
      message: "Invalid IssueStatus",
    })
    .optional(),
  reporterExternalUserId: z.string().trim().optional(),
});
