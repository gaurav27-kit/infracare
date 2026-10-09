/**
 * @file issue.repository.js
 * @description Data access layer for Issue entity using Prisma Client with rich relation selection.
 */

import prisma from "../../config/prisma.js";

const DEFAULT_ISSUE_SELECT = {
  id: true,
  issueNumber: true,
  spaceId: true,
  assetId: true,
  customAssetName: true,
  title: true,
  description: true,
  priority: true,
  status: true,
  reporterExternalUserId: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  space: {
    select: {
      id: true,
      name: true,
      code: true,
      type: true,
      floor: {
        select: {
          id: true,
          name: true,
          level: true,
          building: {
            select: {
              id: true,
              name: true,
              code: true,
            },
          },
        },
      },
    },
  },
  asset: {
    select: {
      id: true,
      name: true,
      code: true,
      status: true,
    },
  },
  attachments: {
    select: {
      id: true,
      fileName: true,
      fileUrl: true,
      fileType: true,
      uploadedAt: true,
    },
    orderBy: {
      uploadedAt: "desc",
    },
  },
};

export class IssueRepository {
  /**
   * Find all active issues with pagination, search, filters, and newest-first sorting.
   * @param {Object} queryOptions
   * @param {number} [queryOptions.page=1]
   * @param {number} [queryOptions.limit=10]
   * @param {string} [queryOptions.search]
   * @param {string} [queryOptions.spaceId]
   * @param {string} [queryOptions.assetId]
   * @param {string} [queryOptions.priority]
   * @param {string} [queryOptions.status]
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async findAll({ page = 1, limit = 10, search, spaceId, assetId, priority, status } = {}) {
    const pageNum = Math.max(1, parseInt(page, 10) || 1);
    const limitNum = Math.max(1, parseInt(limit, 10) || 10);
    const skip = (pageNum - 1) * limitNum;

    const where = { deletedAt: null };

    if (spaceId) {
      where.spaceId = spaceId;
    }

    if (assetId) {
      where.assetId = assetId;
    }

    if (priority) {
      where.priority = priority;
    }

    if (status) {
      where.status = status;
    }

    if (search) {
      where.OR = [
        { issueNumber: { contains: search, mode: "insensitive" } },
        { title: { contains: search, mode: "insensitive" } },
      ];
    }

    const [data, total] = await Promise.all([
      prisma.issue.findMany({
        where,
        skip,
        take: limitNum,
        select: DEFAULT_ISSUE_SELECT,
        orderBy: [{ createdAt: "desc" }],
      }),
      prisma.issue.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limitNum) || 1;

    return {
      data,
      meta: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages,
        hasNext: pageNum < totalPages,
        hasPrevious: pageNum > 1,
      },
    };
  }

  /**
   * Find active issue by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    if (!id) return null;
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
    if (isUuid) {
      return prisma.issue.findFirst({
        where: { id, deletedAt: null },
        select: DEFAULT_ISSUE_SELECT,
      });
    }
    return prisma.issue.findFirst({
      where: { issueNumber: id, deletedAt: null },
      select: DEFAULT_ISSUE_SELECT,
    });
  }

  /**
   * Find active issue by issue number.
   * @param {string} issueNumber
   * @returns {Promise<Object|null>}
   */
  async findByIssueNumber(issueNumber) {
    return prisma.issue.findFirst({
      where: { issueNumber, deletedAt: null },
      select: DEFAULT_ISSUE_SELECT,
    });
  }

  /**
   * Find latest issue for auto-generating sequential issue numbers.
   * @returns {Promise<Object|null>}
   */
  async findLatestIssue() {
    return prisma.issue.findFirst({
      where: { deletedAt: null },
      orderBy: { createdAt: "desc" },
      select: { issueNumber: true },
    });
  }

  /**
   * Create a new issue record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.issue.create({
      data,
      select: DEFAULT_ISSUE_SELECT,
    });
  }

  /**
   * Update an existing issue record by ID.
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    let targetId = id;
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
    if (!isUuid) {
      const existing = await this.findByIssueNumber(id);
      if (existing) targetId = existing.id;
    }
    return prisma.issue.update({
      where: { id: targetId },
      data,
      select: DEFAULT_ISSUE_SELECT,
    });
  }

  /**
   * Soft-delete an issue record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.issue.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: DEFAULT_ISSUE_SELECT,
    });
  }
}

export default new IssueRepository();
