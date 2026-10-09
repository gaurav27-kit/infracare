/**
 * @file workOrder.repository.js
 * @description Data access layer for WorkOrder entity using Prisma Client with rich relation selection.
 */

import prisma from "../../config/prisma.js";

const DEFAULT_WORK_ORDER_SELECT = {
  id: true,
  code: true,
  issueId: true,
  maintenanceDepartmentId: true,
  assignedToExternalUserId: true,
  priority: true,
  status: true,
  scheduledStart: true,
  scheduledEnd: true,
  actualStart: true,
  actualEnd: true,
  cost: true,
  resolutionNotes: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  issue: {
    select: {
      id: true,
      issueNumber: true,
      title: true,
      description: true,
      priority: true,
      status: true,
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
    },
  },
  maintenanceDepartment: {
    select: {
      id: true,
      name: true,
      code: true,
      email: true,
      phone: true,
    },
  },
};

export class WorkOrderRepository {
  /**
   * Find all active work orders with pagination, search, filters, and newest-first sorting.
   * @param {Object} queryOptions
   * @param {number} [queryOptions.page=1]
   * @param {number} [queryOptions.limit=10]
   * @param {string} [queryOptions.search]
   * @param {string} [queryOptions.issueId]
   * @param {string} [queryOptions.maintenanceDepartmentId]
   * @param {string} [queryOptions.priority]
   * @param {string} [queryOptions.status]
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async findAll({ page = 1, limit = 10, search, issueId, maintenanceDepartmentId, priority, status } = {}) {
    const pageNum = Math.max(1, parseInt(page, 10) || 1);
    const limitNum = Math.max(1, parseInt(limit, 10) || 10);
    const skip = (pageNum - 1) * limitNum;

    const where = { deletedAt: null };

    if (issueId) {
      where.issueId = issueId;
    }

    if (maintenanceDepartmentId) {
      where.maintenanceDepartmentId = maintenanceDepartmentId;
    }

    if (priority) {
      where.priority = priority;
    }

    if (status) {
      where.status = status;
    }

    if (search) {
      where.OR = [
        { code: { contains: search, mode: "insensitive" } },
        { issue: { title: { contains: search, mode: "insensitive" } } },
      ];
    }

    const [data, total] = await Promise.all([
      prisma.workOrder.findMany({
        where,
        skip,
        take: limitNum,
        select: DEFAULT_WORK_ORDER_SELECT,
        orderBy: [{ createdAt: "desc" }],
      }),
      prisma.workOrder.count({ where }),
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
   * Find active work order by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    return prisma.workOrder.findFirst({
      where: { id, deletedAt: null },
      select: DEFAULT_WORK_ORDER_SELECT,
    });
  }

  /**
   * Find active work order by code.
   * @param {string} code
   * @returns {Promise<Object|null>}
   */
  async findByCode(code) {
    return prisma.workOrder.findFirst({
      where: { code, deletedAt: null },
      select: DEFAULT_WORK_ORDER_SELECT,
    });
  }

  /**
   * Find active work orders belonging to an issue.
   * @param {string} issueId
   * @returns {Promise<Array>}
   */
  async findByIssue(issueId) {
    return prisma.workOrder.findMany({
      where: { issueId, deletedAt: null },
      select: DEFAULT_WORK_ORDER_SELECT,
      orderBy: [{ createdAt: "desc" }],
    });
  }

  /**
   * Find latest work order for code auto-generation.
   * @returns {Promise<Object|null>}
   */
  async findLatest() {
    return prisma.workOrder.findFirst({
      where: { deletedAt: null },
      orderBy: { createdAt: "desc" },
      select: { code: true },
    });
  }

  /**
   * Create a new work order record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.workOrder.create({
      data,
      select: DEFAULT_WORK_ORDER_SELECT,
    });
  }

  /**
   * Update an existing work order record by ID.
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    return prisma.workOrder.update({
      where: { id },
      data,
      select: DEFAULT_WORK_ORDER_SELECT,
    });
  }

  /**
   * Soft-delete a work order record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.workOrder.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: DEFAULT_WORK_ORDER_SELECT,
    });
  }
}

export default new WorkOrderRepository();
