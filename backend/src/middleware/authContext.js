/**
 * @file authContext.js
 * @description Pluggable User Context Middleware for centralized platform integration.
 * Extracts external user identity from HTTP headers (x-user-id, Authorization Bearer token)
 * and attaches `req.userId` and `req.user` for downstream controllers and services.
 */

export const extractUserContext = (req, res, next) => {
  try {
    // 1. Direct header identification (API gateway / microservice standard)
    const headerUserId = req.headers["x-user-id"] || req.headers["x-auth-user-id"];
    const headerRole = req.headers["x-user-role"] || req.headers["x-auth-user-role"];
    const headerEmail = req.headers["x-user-email"];

    if (headerUserId) {
      req.user = {
        id: String(headerUserId).trim(),
        role: headerRole ? String(headerRole).trim() : "user",
        email: headerEmail ? String(headerEmail).trim() : null,
      };
      req.userId = req.user.id;
      return next();
    }

    // 2. JWT Bearer token inspection (zero-dependency payload extraction)
    const authHeader = req.headers["authorization"] || req.headers["Authorization"];
    if (authHeader && typeof authHeader === "string" && authHeader.startsWith("Bearer ")) {
      const token = authHeader.slice(7).trim();
      const parts = token.split(".");
      if (parts.length === 3) {
        const payloadJson = Buffer.from(parts[1], "base64").toString("utf-8");
        const payload = JSON.parse(payloadJson);
        const resolvedId = payload.sub || payload.id || payload.userId || payload.uid;
        if (resolvedId) {
          req.user = {
            id: String(resolvedId).trim(),
            role: payload.role || payload.user_metadata?.role || "user",
            email: payload.email || null,
          };
          req.userId = req.user.id;
          return next();
        }
      }
    }
  } catch (err) {
    // Silently continue without blocking unauthenticated public routes
  }

  next();
};
