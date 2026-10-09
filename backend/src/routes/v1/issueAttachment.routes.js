/**
 * @file issueAttachment.routes.js
 * @description Express routes for standalone Attachment endpoints.
 */

import { Router } from "express";
import { deleteAttachment } from "../../controllers/issueAttachment.controller.js";

const router = Router();

// DELETE /api/v1/attachments/:id - Delete attachment
router.delete("/:id", deleteAttachment);

export default router;
