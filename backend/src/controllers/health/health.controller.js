/**
 * @file health.controller.js
 * @description Health Check endpoint controller with single Campus configuration status.
 */

import prisma from "../../config/prisma.js";
import campusRepository from "../../repositories/campus/campus.repository.js";
import { ApiResponse } from "../../utils/apiResponse.js";
import { asyncHandler } from "../../utils/asyncHandler.js";

export const getHealth = asyncHandler(async (req, res) => {
  let dbConnected = false;
  let campusConfigured = false;

  try {
    await prisma.$queryRaw`SELECT 1`;
    dbConnected = true;
    campusConfigured = await campusRepository.exists();
  } catch (error) {
    dbConnected = false;
    campusConfigured = false;
  }

  const healthStatus = {
    service: "infracare-backend",
    version: process.env.npm_package_version || "1.0.0",
    environment: process.env.NODE_ENV || "development",
    uptime: process.uptime(),
    database: dbConnected ? "UP" : "DOWN",
    campusConfigured,
    timestamp: new Date().toISOString(),
  };

  const statusCode = dbConnected ? 200 : 503;
  return ApiResponse.success(res, "Health check completed", healthStatus, statusCode);
});
