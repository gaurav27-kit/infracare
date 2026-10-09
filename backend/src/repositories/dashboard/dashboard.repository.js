/**
 * @file dashboard.repository.js
 * @description Data access layer for read-only Dashboard aggregations and summaries using Prisma.
 */

import prisma from "../../config/prisma.js";

export class DashboardRepository {
  /**
   * Get campus details and counts for all active entities.
   * @returns {Promise<Object>}
   */
  async getSummary() {
    const [campus, buildings, floors, spaces, assets, issues, workOrders] = await Promise.all([
      prisma.campus.findFirst({
        where: { deletedAt: null },
        select: { name: true, code: true },
      }),
      prisma.building.count({ where: { deletedAt: null } }),
      prisma.floor.count({ where: { deletedAt: null } }),
      prisma.space.count({ where: { deletedAt: null } }),
      prisma.asset.count({ where: { deletedAt: null } }),
      prisma.issue.count({ where: { deletedAt: null } }),
      prisma.workOrder.count({ where: { deletedAt: null } }),
    ]);

    return {
      campus: campus ? { name: campus.name, code: campus.code } : { name: "", code: "" },
      counts: {
        buildings,
        floors,
        spaces,
        assets,
        issues,
        workOrders,
      },
    };
  }

  /**
   * Get issue statistics grouped by status and priority for active records.
   * @returns {Promise<{ statusGroup: Array, priorityGroup: Array }>}
   */
  async getIssueStatistics() {
    const [statusGroup, priorityGroup] = await Promise.all([
      prisma.issue.groupBy({
        by: ["status"],
        where: { deletedAt: null },
        _count: { status: true },
      }),
      prisma.issue.groupBy({
        by: ["priority"],
        where: { deletedAt: null },
        _count: { priority: true },
      }),
    ]);

    return { statusGroup, priorityGroup };
  }

  /**
   * Get asset statistics grouped by status for active records.
   * @returns {Promise<Array>}
   */
  async getAssetStatistics() {
    return prisma.asset.groupBy({
      by: ["status"],
      where: { deletedAt: null },
      _count: { status: true },
    });
  }

  /**
   * Get maintenance overview counts for open issues and work order statuses.
   * @returns {Promise<Object>}
   */
  async getMaintenanceOverview() {
    const [openIssues, scheduledWorkOrders, inProgressWorkOrders, completedWorkOrders] = await Promise.all([
      prisma.issue.count({ where: { status: "OPEN", deletedAt: null } }),
      prisma.workOrder.count({ where: { status: "SCHEDULED", deletedAt: null } }),
      prisma.workOrder.count({ where: { status: "IN_PROGRESS", deletedAt: null } }),
      prisma.workOrder.count({ where: { status: "COMPLETED", deletedAt: null } }),
    ]);

    return {
      openIssues,
      scheduledWorkOrders,
      inProgressWorkOrders,
      completedWorkOrders,
    };
  }

  /**
   * Get latest 5 active issues with lightweight field selections.
   * @returns {Promise<Array>}
   */
  async getRecentIssues() {
    return prisma.issue.findMany({
      where: { deletedAt: null },
      take: 5,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        issueNumber: true,
        title: true,
        priority: true,
        status: true,
        createdAt: true,
        space: {
          select: {
            name: true,
            floor: {
              select: {
                name: true,
                building: {
                  select: {
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
    });
  }

  /**
   * Get latest 5 active work orders with lightweight field selections.
   * @returns {Promise<Array>}
   */
  async getRecentWorkOrders() {
    return prisma.workOrder.findMany({
      where: { deletedAt: null },
      take: 5,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        code: true,
        status: true,
        priority: true,
        createdAt: true,
        issue: {
          select: {
            issueNumber: true,
            title: true,
          },
        },
        maintenanceDepartment: {
          select: {
            name: true,
          },
        },
      },
    });
  }
}

export default new DashboardRepository();
