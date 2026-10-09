/**
 * @file health.routes.js
 * @description Health Check route registration.
 */

import { Router } from "express";
import { getHealth } from "../../controllers/health/health.controller.js";

const router = Router();

router.get("/", getHealth);

export default router;
