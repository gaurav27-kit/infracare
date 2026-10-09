/**
 * @file issue.controller.js
 * @description HTTP Controller handling requests for Issue entities.
 */

import issueService from "../services/issue.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/issues
 * @desc    Get paginated active issue entities
 * @access  Public / Authenticated
 */
export const getIssues = asyncHandler(async (req, res) => {
  const { data, meta } = await issueService.getAllIssues(req.query);
  return ApiResponse.success(res, "Issues retrieved successfully", data, 200, meta);
});

/**
 * @route   GET /api/v1/issues/:id
 * @desc    Get issue details by ID
 * @access  Public / Authenticated
 */
export const getIssueById = asyncHandler(async (req, res) => {
  const issue = await issueService.getIssueById(req.params.id);
  return ApiResponse.success(res, "Issue details retrieved successfully", issue);
});

/**
 * @route   POST /api/v1/issues
 * @desc    Create a new issue entity
 * @access  Public / Authenticated
 */
export const createIssue = asyncHandler(async (req, res) => {
  const payload = {
    ...req.body,
    reporterExternalUserId: req.body.reporterExternalUserId || req.userId || undefined,
  };
  const newIssue = await issueService.createIssue(payload);
  return ApiResponse.success(res, "Issue created successfully", newIssue, 201);
});

/**
 * @route   PUT /api/v1/issues/:id
 * @desc    Update issue details by ID
 * @access  Public / Authenticated
 */
export const updateIssue = asyncHandler(async (req, res) => {
  const payload = {
    ...req.body,
    updatedByExternalUserId: req.body.updatedByExternalUserId || req.userId || undefined,
  };
  const updatedIssue = await issueService.updateIssue(req.params.id, payload);
  return ApiResponse.success(res, "Issue updated successfully", updatedIssue);
});

/**
 * @route   DELETE /api/v1/issues/:id
 * @desc    Soft-delete issue by ID
 * @access  Public / Authenticated
 */
export const deleteIssue = asyncHandler(async (req, res) => {
  const result = await issueService.deleteIssue(req.params.id);
  return ApiResponse.success(res, "Issue deleted successfully", result);
});
