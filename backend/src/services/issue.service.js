/**
 * @file issue.service.js
 * @description Business logic layer for Issue entity management with validation and audit logging.
 */

import issueRepository from "../repositories/issue/issue.repository.js";
import spaceRepository from "../repositories/space/space.repository.js";
import assetRepository from "../repositories/asset/asset.repository.js";
import { ApiError } from "../utils/apiError.js";
import { IssuePriority, IssueStatus } from "../types/enums.js";
import logger from "../utils/logger.js";

export class IssueService {
  /**
   * Auto-generate next sequential readable issue number (ISS-0001, ISS-0002, etc.).
   * @returns {Promise<string>}
   */
  async generateIssueNumber() {
    const latestIssue = await issueRepository.findLatestIssue();
    let nextCount = 1;

    if (latestIssue && latestIssue.issueNumber) {
      const match = latestIssue.issueNumber.match(/^ISS-(\d+)$/);
      if (match) {
        nextCount = parseInt(match[1], 10) + 1;
      }
    }

    let candidate = `ISS-${String(nextCount).padStart(4, "0")}`;
    let existing = await issueRepository.findByIssueNumber(candidate);

    while (existing) {
      nextCount++;
      candidate = `ISS-${String(nextCount).padStart(4, "0")}`;
      existing = await issueRepository.findByIssueNumber(candidate);
    }

    return candidate;
  }

  /**
   * Retrieve active issues with optional search, pagination, and filters.
   * @param {Object} queryParams
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async getAllIssues(queryParams = {}) {
    return issueRepository.findAll(queryParams);
  }

  /**
   * Retrieve an issue by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async getIssueById(id) {
    const issue = await issueRepository.findById(id);
    if (!issue) {
      throw ApiError.notFound(`Issue with ID ${id} not found`);
    }
    return issue;
  }

  /**
   * Create a new issue record.
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async createIssue(payload) {
    const {
      spaceId,
      assetId,
      customAssetName,
      title,
      description,
      priority = IssuePriority.MEDIUM,
      status = IssueStatus.OPEN,
      reporterExternalUserId = "ext-user-1",
    } = payload;

    // Business Rule 1: Verify active Space exists
    const space = await spaceRepository.findById(spaceId);
    if (!space) {
      throw ApiError.notFound(`Space with ID ${spaceId} not found`);
    }

    // Business Rule 2: If Asset is supplied, check if it matches a DB asset
    let validAssetId = null;
    let resolvedCustomAssetName = customAssetName || null;
    if (assetId) {
      const isUuid = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.test(assetId);
      if (isUuid) {
        const asset = await assetRepository.findById(assetId);
        if (!asset) {
          throw ApiError.badRequest(`Asset with ID ${assetId} not found`);
        }
        if (asset.spaceId !== spaceId) {
          throw ApiError.badRequest(
            `Asset with ID ${assetId} does not belong to Space ${spaceId}`
          );
        }
        validAssetId = asset.id;
      } else {
        // Predefined dropdown item or custom name without DB UUID
        resolvedCustomAssetName = resolvedCustomAssetName || assetId;
      }
    }

    // Business Rule 3: Validate Priority and Status enums if provided
    const resolvedPriority = priority || IssuePriority.MEDIUM;
    if (!Object.values(IssuePriority).includes(resolvedPriority)) {
      throw ApiError.badRequest(`Invalid IssuePriority: '${resolvedPriority}'`);
    }

    const resolvedStatus = status || IssueStatus.OPEN;
    if (!Object.values(IssueStatus).includes(resolvedStatus)) {
      throw ApiError.badRequest(`Invalid IssueStatus: '${resolvedStatus}'`);
    }

    // Auto-generate unique sequential Issue Number
    const issueNumber = await this.generateIssueNumber();

    const createData = {
      issueNumber,
      spaceId: space.id,
      assetId: validAssetId,
      customAssetName: resolvedCustomAssetName,
      title,
      description,
      priority: resolvedPriority,
      status: resolvedStatus,
      reporterExternalUserId,
    };

    if (Array.isArray(payload.attachments) && payload.attachments.length > 0) {
      const validAttachments = payload.attachments
        .filter((a) => a && (a.fileUrl || a.uploadedUrl))
        .map((a) => ({
          fileName: a.fileName || a.name || "attachment.jpg",
          fileUrl: a.fileUrl || a.uploadedUrl,
          fileType: a.fileType || "image/jpeg",
        }));
      if (validAttachments.length > 0) {
        createData.attachments = {
          create: validAttachments,
        };
      }
    }

    const newIssue = await issueRepository.create(createData);

    // Audit Logging
    logger.info("Issue Created", {
      issueId: newIssue.id,
      issueNumber: newIssue.issueNumber,
      title: newIssue.title,
      customAssetName: newIssue.customAssetName,
      timestamp: new Date().toISOString(),
    });

    return newIssue;
  }

  /**
   * Update an existing issue record by ID.
   * @param {string} id
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async updateIssue(id, payload) {
    const issue = await issueRepository.findById(id);
    if (!issue) {
      throw ApiError.notFound(`Issue with ID ${id} not found`);
    }

    const { spaceId, assetId, customAssetName, title, description, priority, status } = payload;
    const targetSpaceId = spaceId !== undefined ? spaceId : issue.spaceId;
    const updateData = {};

    if (customAssetName !== undefined) {
      updateData.customAssetName = customAssetName;
    }

    // Validate Space update if changed
    if (spaceId !== undefined && spaceId !== issue.spaceId) {
      const targetSpace = await spaceRepository.findById(spaceId);
      if (!targetSpace) {
        throw ApiError.notFound(`Space with ID ${spaceId} not found`);
      }
      updateData.spaceId = spaceId;
    }

    // Validate Asset update or existing asset association with target space
    const targetAssetId = assetId !== undefined ? assetId : issue.assetId;
    if (targetAssetId) {
      const asset = await assetRepository.findById(targetAssetId);
      if (!asset) {
        throw ApiError.badRequest(`Asset with ID ${targetAssetId} not found`);
      }
      if (asset.spaceId !== targetSpaceId) {
        throw ApiError.badRequest(`Asset with ID ${targetAssetId} does not belong to Space ${targetSpaceId}`);
      }
      if (assetId !== undefined) {
        updateData.assetId = assetId;
      }
    } else if (assetId === null) {
      updateData.assetId = null;
    }

    if (priority !== undefined) {
      if (!Object.values(IssuePriority).includes(priority)) {
        throw ApiError.badRequest(`Invalid IssuePriority: '${priority}'`);
      }
      updateData.priority = priority;
    }

    if (status !== undefined) {
      if (!Object.values(IssueStatus).includes(status)) {
        throw ApiError.badRequest(`Invalid IssueStatus: '${status}'`);
      }
      updateData.status = status;
    }

    if (title !== undefined) {
      updateData.title = title;
    }

    if (description !== undefined) {
      updateData.description = description;
    }

    if (Object.keys(updateData).length === 0) {
      return issue;
    }

    const updatedIssue = await issueRepository.update(id, updateData);

    // Audit Logging
    logger.info("Issue Updated", {
      issueId: updatedIssue.id,
      issueNumber: updatedIssue.issueNumber,
      title: updatedIssue.title,
      timestamp: new Date().toISOString(),
    });

    return updatedIssue;
  }

  /**
   * Soft-delete an issue record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteIssue(id) {
    const issue = await issueRepository.findById(id);
    if (!issue) {
      throw ApiError.notFound(`Issue with ID ${id} not found`);
    }

    await issueRepository.delete(id);

    // Audit Logging
    logger.info("Issue Soft Deleted", {
      issueId: issue.id,
      issueNumber: issue.issueNumber,
      title: issue.title,
      timestamp: new Date().toISOString(),
    });

    return { id, deleted: true };
  }
}

export default new IssueService();
