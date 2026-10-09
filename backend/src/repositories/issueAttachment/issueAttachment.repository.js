/**
 * @file issueAttachment.repository.js
 * @description Data access layer for IssueAttachment entity using Prisma Client.
 */

import prisma from "../../config/prisma.js";

const DEFAULT_ATTACHMENT_SELECT = {
  id: true,
  issueId: true,
  fileName: true,
  fileUrl: true,
  fileType: true,
  uploadedAt: true,
  issue: {
    select: {
      issueNumber: true,
      title: true,
    },
  },
};

export class IssueAttachmentRepository {
  /**
   * Find all attachments for an issue.
   * @param {string} issueId
   * @returns {Promise<Array>}
   */
  async findByIssue(issueId) {
    return prisma.issueAttachment.findMany({
      where: { issueId },
      select: DEFAULT_ATTACHMENT_SELECT,
      orderBy: { uploadedAt: "desc" },
    });
  }

  /**
   * Find attachment by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    return prisma.issueAttachment.findFirst({
      where: { id },
      select: DEFAULT_ATTACHMENT_SELECT,
    });
  }

  /**
   * Create a new attachment record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.issueAttachment.create({
      data,
      select: DEFAULT_ATTACHMENT_SELECT,
    });
  }

  /**
   * Delete an attachment record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.issueAttachment.delete({
      where: { id },
    });
  }
}

export default new IssueAttachmentRepository();
