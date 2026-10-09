/**
 * @file requestLogger.js
 * @description Middleware to log HTTP request details using Winston logger.
 */

import logger from "../utils/logger.js";

export const requestLogger = (req, res, next) => {
  if (req.method === "GET") {
    return next();
  }

  const startTime = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - startTime;
    const logData = {
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      durationMs: duration,
    };

    if (res.statusCode >= 500) {
      logger.error({ message: "Request completed with server error", ...logData });
    } else if (res.statusCode >= 400) {
      logger.warn({ message: "Request completed with client error", ...logData });
    } else {
      logger.info({ message: "Request completed", ...logData });
    }
  });

  next();
};
