/**
 * @file asset.validator.js
 * @description Zod schema validation for Asset request payloads using Master Data Foundation limits.
 */

import { z } from "zod";
import { VALIDATION_LIMITS } from "../types/index.js";
import { AssetStatus } from "../types/enums.js";

const A = VALIDATION_LIMITS.ASSET;

export const createAssetSchema = z
  .object({
    spaceId: z.string({ required_error: "Space ID is required" }).uuid("Invalid Space ID format"),
    categoryId: z.string().uuid("Invalid Category ID format").optional(),
    assetCategoryId: z.string().uuid("Invalid Category ID format").optional(),
    name: z
      .string({ required_error: "Asset name is required" })
      .trim()
      .min(A.NAME_MIN, `Asset name must be at least ${A.NAME_MIN} characters`)
      .max(A.NAME_MAX, `Asset name cannot exceed ${A.NAME_MAX} characters`),
    code: z
      .string({ required_error: "Asset code is required" })
      .trim()
      .min(2, "Asset code must be at least 2 characters")
      .max(30, "Asset code cannot exceed 30 characters")
      .toUpperCase(),
    serialNumber: z
      .string()
      .trim()
      .min(A.SERIAL_NUMBER_MIN, `Serial number must be at least ${A.SERIAL_NUMBER_MIN} characters`)
      .max(A.SERIAL_NUMBER_MAX, `Serial number cannot exceed ${A.SERIAL_NUMBER_MAX} characters`)
      .nullable()
      .optional(),
    qrCode: z.string().trim().nullable().optional(),
    status: z.nativeEnum(AssetStatus, { invalid_type_error: "Invalid AssetStatus" }).optional(),
    manufacturer: z.string().trim().nullable().optional(),
    model: z.string().trim().nullable().optional(),
    purchaseDate: z.string().trim().nullable().optional(),
    installationDate: z.string().trim().nullable().optional(),
    warrantyExpiry: z.string().trim().nullable().optional(),
  })
  .refine((data) => data.categoryId || data.assetCategoryId, {
    message: "Category ID is required",
    path: ["categoryId"],
  });

export const updateAssetSchema = z.object({
  spaceId: z.string().uuid("Invalid Space ID format").optional(),
  categoryId: z.string().uuid("Invalid Category ID format").optional(),
  assetCategoryId: z.string().uuid("Invalid Category ID format").optional(),
  name: z
    .string()
    .trim()
    .min(A.NAME_MIN, `Asset name must be at least ${A.NAME_MIN} characters`)
    .max(A.NAME_MAX, `Asset name cannot exceed ${A.NAME_MAX} characters`)
    .optional(),
  code: z
    .string()
    .trim()
    .min(2, "Asset code must be at least 2 characters")
    .max(30, "Asset code cannot exceed 30 characters")
    .toUpperCase()
    .optional(),
  serialNumber: z
    .string()
    .trim()
    .min(A.SERIAL_NUMBER_MIN, `Serial number must be at least ${A.SERIAL_NUMBER_MIN} characters`)
    .max(A.SERIAL_NUMBER_MAX, `Serial number cannot exceed ${A.SERIAL_NUMBER_MAX} characters`)
    .nullable()
    .optional(),
  qrCode: z.string().trim().nullable().optional(),
  status: z.nativeEnum(AssetStatus, { invalid_type_error: "Invalid AssetStatus" }).optional(),
  manufacturer: z.string().trim().nullable().optional(),
  model: z.string().trim().nullable().optional(),
  purchaseDate: z.string().trim().nullable().optional(),
  installationDate: z.string().trim().nullable().optional(),
  warrantyExpiry: z.string().trim().nullable().optional(),
});
