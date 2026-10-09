import express from "express";
import cors from "cors";
import helmet from "helmet";

import v1Router from "./routes/v1/index.js";
import { requestLogger } from "./middleware/requestLogger.js";
import { extractUserContext } from "./middleware/authContext.js";
import { errorHandler } from "./middleware/errorHandler.js";
import { ApiError } from "./utils/apiError.js";

const app = express();

app.use(helmet({ contentSecurityPolicy: false }));

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(",").map((s) => s.trim())
  : [process.env.CLIENT_URL, process.env.FRONTEND_URL, "http://localhost:5173", "http://127.0.0.1:5173"].filter(Boolean);

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow non-browser requests (e.g. mobile Flutter app, Postman, curl)
      if (!origin || allowedOrigins.includes("*") || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      return callback(new Error(`CORS blocked request from origin: ${origin}`));
    },
    credentials: true,
  })
);

app.use(express.json({ limit: "10mb" }));
app.use(requestLogger);
app.use(extractUserContext);

// Root health & service ping
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "InfraCare API is running",
    service: "infracare-backend",
    version: "1.0.0",
    health: "/api/v1/health",
  });
});

app.use("/api/v1", v1Router);

app.use((req, res, next) => next(ApiError.notFound(`Route ${req.method} ${req.originalUrl} not found`)));
app.use(errorHandler);

export default app;
