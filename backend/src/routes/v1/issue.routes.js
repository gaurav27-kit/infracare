/**
 * @file issue.routes.js
 * @description Express routes for Issue CRUD and Issue Attachment endpoints.
 */

import { Router } from "express";
import {
  getIssues,
  getIssueById,
  createIssue,
  updateIssue,
  deleteIssue,
} from "../../controllers/issue.controller.js";
import {
  getAttachmentsByIssue,
  createAttachment,
} from "../../controllers/issueAttachment.controller.js";
import { validate } from "../../middleware/validate.js";
import { createIssueSchema, updateIssueSchema } from "../../validators/issue.validator.js";
import { createAttachmentSchema } from "../../validators/issueAttachment.validator.js";

import multer from "multer";

const router = Router();

// GET /api/v1/issues - Get paginated issues
router.get("/", getIssues);

// GET /api/v1/issues/:id - Get issue by ID
router.get("/:id", getIssueById);

// POST /api/v1/issues - Create issue
router.post("/", validate(createIssueSchema), createIssue);

// PUT /api/v1/issues/:id - Update issue
router.put("/:id", validate(updateIssueSchema), updateIssue);

// DELETE /api/v1/issues/:id - Delete issue
router.delete("/:id", deleteIssue);

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB per file
  },
});

const handleOptionalUpload = (req, res, next) => {
  const contentType = req.headers["content-type"] || "";
  if (contentType.includes("multipart/form-data")) {
    upload.single("file")(req, res, (err) => {
      if (err) {
        return res.status(400).json({
          success: false,
          message: err.message,
        });
      }
      if (req.file) {
        req.body.fileName = req.body.fileName || req.file.originalname;
        req.body.fileType = req.body.fileType || req.file.mimetype;
      }
      next();
    });
  } else {
    next();
  }
};

// GET /api/v1/issues/:issueId/attachments - Get issue attachments
router.get("/:issueId/attachments", getAttachmentsByIssue);

// POST /api/v1/issues/:issueId/attachments - Add issue attachment
router.post(
  "/:issueId/attachments",
  handleOptionalUpload,
  validate(createAttachmentSchema),
  createAttachment
);

export default router;
