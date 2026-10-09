/**
 * @file issueAttachment.service.js
 * @description Business logic layer for IssueAttachment entity management with validation and audit logging.
 */

import issueAttachmentRepository from "../repositories/issueAttachment/issueAttachment.repository.js";
import issueRepository from "../repositories/issue/issue.repository.js";
import { ApiError } from "../utils/apiError.js";
import logger from "../utils/logger.js";

export class IssueAttachmentService {
  /**
   * Retrieve all attachments belonging to an issue.
   * @param {string} issueId
   * @returns {Promise<Array>}
   */
  async getAttachmentsByIssue(issueId) {
    const issue = await issueRepository.findById(issueId);
    if (!issue) {
      throw ApiError.notFound(`Issue with ID ${issueId} not found`);
    }
    return issueAttachmentRepository.findByIssue(issue.id);
  }

  /**
   * Create a new attachment metadata record under an issue.
   * @param {string} issueId
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async createAttachment(issueId, payload) {
    const issue = await issueRepository.findById(issueId);
    if (!issue) {
      throw ApiError.notFound(`Issue with ID ${issueId} not found`);
    }

    const { fileName, fileUrl, fileType } = payload;

    const attachment = await issueAttachmentRepository.create({
      issueId: issue.id,
      fileName,
      fileUrl,
      fileType: fileType || "image/jpeg",
    });

    // Audit Logging
    logger.info("Attachment Added", {
      id: attachment.id,
      issueId: issue.id,
      issueNumber: issue.issueNumber,
      fileName: attachment.fileName,
      timestamp: new Date().toISOString(),
    });

    return attachment;
  }

  /**
   * Delete an attachment by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteAttachment(id) {
    const attachment = await issueAttachmentRepository.findById(id);
    if (!attachment) {
      throw ApiError.notFound(`Attachment with ID ${id} not found`);
    }

    await issueAttachmentRepository.delete(id);

    // Audit Logging
    logger.info("Attachment Deleted", {
      id,
      issueId: attachment.issueId,
      timestamp: new Date().toISOString(),
    });

    return { id, deleted: true };
  }
}

export default new IssueAttachmentService();
