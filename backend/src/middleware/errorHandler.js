/**
 * @file errorHandler.js
 * @description Centralized Express error handling middleware.
 */

import logger from "../utils/logger.js";
import { ApiError } from "../utils/apiError.js";

/**
 * Transform known database/framework errors into ApiError instances.
 */
const normalizeError = (err) => {
  // Prisma error handling (known request error)
  if (err.code && typeof err.code === "string" && err.code.startsWith("P")) {
    // Unique constraint failed
    if (err.code === "P2002") {
      const targets = err.meta?.target || "fields";
      return new ApiError(409, `Conflict: Duplicate value for key (${targets})`);
    }
    // Record not found
    if (err.code === "P2025") {
      return new ApiError(404, err.meta?.cause || "Resource not found");
    }
    // General Prisma client error
    return new ApiError(400, `Database error: ${err.message}`);
  }

  // Express rate-limit error
  if (err.status === 429) {
    return new ApiError(429, err.message || "Too many requests. Please try again later.");
  }

  // Pass through existing ApiErrors unchanged
  if (err instanceof ApiError) {
    return err;
  }

  // Unknown / programmer error
  return new ApiError(500, "An unexpected error occurred. Please try again.");
};

/**
 * Global Express error handler.
 */
// eslint-disable-next-line no-unused-vars
export const errorHandler = (err, req, res, next) => {
  const normalizedError = normalizeError(err);

  const logPayload = {
    method: req.method,
    url: req.originalUrl,
    statusCode: normalizedError.statusCode,
    message: normalizedError.message,
    errors: normalizedError.errors,
    userId: req.user?.id,
    ip: req.ip,
  };

  if (normalizedError.statusCode >= 500) {
    logPayload.stack = err.stack;
    logger.error({ message: "Unhandled server error", ...logPayload });
  } else {
    logger.warn({ message: "Operational error", ...logPayload });
  }

  // ─── Response ─────────────────────────────────────────────────────────────
  return res.status(normalizedError.statusCode).json({
    success: false,
    message: normalizedError.message,
    ...(normalizedError.errors.length > 0 && { errors: normalizedError.errors }),
    // Only include requestId in response if you add request-id middleware later
  });
};
