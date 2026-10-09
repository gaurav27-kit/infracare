/**
 * @file server.js
 * @description Application entry point — connects to PostgreSQL via Prisma and starts Express listener.
 */

import "dotenv/config";
import app from "./app.js";
import { connectDB } from "./config/prisma.js";
import logger from "./utils/logger.js";

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    // ─── 1. Database ──────────────────────────────────────────────────────────
    await connectDB();

    // ─── 2. Start HTTP server ─────────────────────────────────────────────────
    const server = app.listen(PORT, "0.0.0.0", () => {
      logger.info({
        message: `🚀 InfraCare server running`,
        port: PORT,
        environment: process.env.NODE_ENV || "development",
        url: `http://127.0.0.1:${PORT}`,
      });
    });

    // ─── 3. Graceful shutdown ─────────────────────────────────────────────────
    const gracefulShutdown = (signal) => {
      logger.info({ message: `${signal} received — shutting down gracefully` });
      server.close(() => {
        logger.info({ message: "Server closed. All connections drained." });
        process.exit(0);
      });

      // Force-exit if graceful shutdown takes too long (10s timeout)
      setTimeout(() => {
        logger.error({ message: "Forced shutdown — server did not drain in time" });
        process.exit(1);
      }, 10000);
    };

    process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
    process.on("SIGINT", () => gracefulShutdown("SIGINT"));

    // Catch unhandled rejections — log and continue
    process.on("unhandledRejection", (reason) => {
      logger.error({
        message: "Unhandled Promise rejection",
        error: reason instanceof Error ? reason.message : reason,
        stack: reason instanceof Error ? reason.stack : undefined,
      });
    });

    // Catch uncaught exceptions — log and exit
    process.on("uncaughtException", (error) => {
      logger.error({
        message: "Uncaught exception — shutting down",
        error: error.message,
        stack: error.stack,
      });
      process.exit(1);
    });

  } catch (err) {
    logger.error({ message: "❌ Failed to start server", error: err.message, stack: err.stack });
    process.exit(1);
  }
}

startServer();