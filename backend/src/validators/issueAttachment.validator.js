/**
 * @file issueAttachment.validator.js
 * @description Zod schema validation for IssueAttachment request payloads.
 */

import { z } from "zod";

export const createAttachmentSchema = z.object({
  fileName: z
    .string({ required_error: "File name is required" })
    .trim()
    .min(1, "File name cannot be empty")
    .max(255, "File name cannot exceed 255 characters"),
  fileUrl: z.string().trim().optional(),
  fileType: z.string().trim().max(100).optional(),
});
