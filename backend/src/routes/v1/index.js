/**
 * @file index.js
 * @description Main Router aggregating all v1 API route groups.
 */

import { Router } from "express";
import healthRouter from "./health.routes.js";
import campusRouter from "./campus.routes.js";
import buildingRouter from "./building.routes.js";
import floorRouter from "./floor.routes.js";
import spaceRouter from "./space.routes.js";
import assetRouter from "./asset.routes.js";
import issueRouter from "./issue.routes.js";
import workOrderRouter from "./workOrder.routes.js";
import attachmentRouter from "./issueAttachment.routes.js";
import dashboardRouter from "./dashboard.routes.js";

const router = Router();

router.use("/health", healthRouter);
router.use("/campus", campusRouter);
router.use("/buildings", buildingRouter);
router.use("/floors", floorRouter);
router.use("/spaces", spaceRouter);
router.use("/assets", assetRouter);
router.use("/issues", issueRouter);
router.use("/work-orders", workOrderRouter);
router.use("/attachments", attachmentRouter);
router.use("/dashboard", dashboardRouter);

export default router;
