/**
 * @file prisma.js
 * @description PostgreSQL database client and connection verification via Prisma.
 */

import { prisma } from "../../prisma/client.js";
import logger from "../utils/logger.js";

export const connectDB = async () => {
  try {
    // Verify connection by running a simple query
    await prisma.$queryRaw`SELECT 1`;
    logger.info({ message: "✅ PostgreSQL connected successfully via Prisma" });
  } catch (error) {
    logger.error({ message: "❌ PostgreSQL Connection Error via Prisma", error: error.message });
    process.exit(1);
  }
};

export default prisma;
