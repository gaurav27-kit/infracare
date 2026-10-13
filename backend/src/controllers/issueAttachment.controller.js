/**
 * @file issueAttachment.controller.js
 * @description HTTP Controller handling requests for IssueAttachment entities.
 */

import issueAttachmentService from "../services/issueAttachment.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import cloudinary from "../config/cloudinary.js";
import { uploadToCloudinary } from "../utils/cloudinaryUpload.js";
import logger from "../utils/logger.js";

/**
 * @route   GET /api/v1/issues/:issueId/attachments
 * @desc    Get attachments for a specific issue
 * @access  Public / Authenticated
 */
export const getAttachmentsByIssue = asyncHandler(async (req, res) => {
  const attachments = await issueAttachmentService.getAttachmentsByIssue(req.params.issueId);
  return ApiResponse.success(res, "Attachments retrieved successfully", attachments);
});

/**
 * @route   POST /api/v1/issues/:issueId/attachments
 * @desc    Add attachment metadata to an issue
 * @access  Public / Authenticated
 */
export const createAttachment = asyncHandler(async (req, res) => {
  let fileName = req.body?.fileName || "attachment.jpg";
  let fileUrl = req.body?.fileUrl;
  let fileType = req.body?.fileType || "image/jpeg";

  const targetFolder = process.env.CLOUDINARY_FOLDER || "infracare/issues";

  // Case 1: Uploaded via multipart form (req.file)
  if (req.file) {
    try {
      const uploadResult = await uploadToCloudinary(req.file.buffer, targetFolder);
      fileUrl = uploadResult.secureUrl || uploadResult.url;
      fileName = req.file.originalname || fileName;
      fileType = req.file.mimetype || fileType;
    } catch (uploadErr) {
      logger.error("Cloudinary multipart upload failed:", uploadErr);
      return ApiResponse.error(res, `Failed to upload image to Cloudinary: ${uploadErr.message}`, 500);
    }
  } else if (fileUrl && fileUrl.startsWith("data:")) {
    // Case 2: Base64 data URI uploaded in JSON body
    try {
      const uploadResult = await cloudinary.uploader.upload(fileUrl, {
        folder: targetFolder,
        resource_type: "auto",
      });
      fileUrl = uploadResult.secure_url || uploadResult.url;
    } catch (uploadErr) {
      logger.error("Cloudinary base64 upload failed:", uploadErr);
      return ApiResponse.error(res, `Failed to upload image to Cloudinary: ${uploadErr.message}`, 500);
    }
  }

  if (!fileUrl) {
    return ApiResponse.error(res, "A file upload or valid fileUrl is required", 400);
  }

  const newAttachment = await issueAttachmentService.createAttachment(req.params.issueId, {
    fileName,
    fileUrl,
    fileType,
  });
  return ApiResponse.success(res, "Attachment added successfully", newAttachment, 201);
});

/**
 * @route   DELETE /api/v1/attachments/:id
 * @desc    Delete an attachment record by ID
 * @access  Public / Authenticated
 */
export const deleteAttachment = asyncHandler(async (req, res) => {
  const result = await issueAttachmentService.deleteAttachment(req.params.id);
  return ApiResponse.success(res, "Attachment deleted successfully", result);
});
