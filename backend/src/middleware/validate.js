/**
 * @file validate.js
 * @description Express middleware to validate request body using Zod schemas.
 */

import { ApiError } from "../utils/apiError.js";

export const validate = (schema) => (req, res, next) => {
  try {
    const parsed = schema.parse(req.body);
    req.body = parsed;
    next();
  } catch (error) {
    const issues = error.issues || error.errors;
    if (Array.isArray(issues) && issues.length > 0) {
      const issueMessages = issues.map((err) => `${err.path.join(".")}: ${err.message}`).join(", ");
      return next(ApiError.badRequest(`Validation error: ${issueMessages}`));
    }
    return next(ApiError.badRequest(error.message || "Invalid request payload"));
  }
};

