/**
 * @file dashboard.service.js
 * @description Service layer for read-only Dashboard aggregations and formatted statistics.
 */

import dashboardRepository from "../repositories/dashboard/dashboard.repository.js";
import { IssueStatus, IssuePriority, AssetStatus } from "../types/enums.js";

export class DashboardService {
  /**
   * Get campus summary and active entity counts.
   * @returns {Promise<Object>}
   */
  async getSummary() {
    return dashboardRepository.getSummary();
  }

  /**
   * Get formatted issue statistics with guaranteed zero-default enum maps.
   * @returns {Promise<Object>}
   */
  async getIssueStatistics() {
    const { statusGroup, priorityGroup } = await dashboardRepository.getIssueStatistics();

    const statusMap = Object.values(IssueStatus).reduce((acc, curr) => {
      acc[curr] = 0;
      return acc;
    }, {});

    statusGroup.forEach((item) => {
      if (item.status && statusMap[item.status] !== undefined) {
        statusMap[item.status] = item._count.status;
      }
    });

    const priorityMap = Object.values(IssuePriority).reduce((acc, curr) => {
      acc[curr] = 0;
      return acc;
    }, {});

    priorityGroup.forEach((item) => {
      if (item.priority && priorityMap[item.priority] !== undefined) {
        priorityMap[item.priority] = item._count.priority;
      }
    });

    return {
      status: statusMap,
      priority: priorityMap,
    };
  }

  /**
   * Get formatted asset statistics with guaranteed zero-default enum map.
   * @returns {Promise<Object>}
   */
  async getAssetStatistics() {
    const assetGroup = await dashboardRepository.getAssetStatistics();

    const statusMap = Object.values(AssetStatus).reduce((acc, curr) => {
      acc[curr] = 0;
      return acc;
    }, {});

    assetGroup.forEach((item) => {
      if (item.status && statusMap[item.status] !== undefined) {
        statusMap[item.status] = item._count.status;
      }
    });

    return {
      status: statusMap,
    };
  }

  /**
   * Get maintenance overview counts for open issues and work order statuses.
   * @returns {Promise<Object>}
   */
  async getMaintenanceOverview() {
    return dashboardRepository.getMaintenanceOverview();
  }

  /**
   * Get top 5 recent issues with lightweight formatted structure.
   * @returns {Promise<Array>}
   */
  async getRecentIssues() {
    const issues = await dashboardRepository.getRecentIssues();
    return issues.map((issue) => ({
      id: issue.id,
      issueNumber: issue.issueNumber,
      title: issue.title,
      priority: issue.priority,
      status: issue.status,
      createdAt: issue.createdAt,
      space: issue.space ? { name: issue.space.name } : null,
      building: issue.space?.floor?.building ? { name: issue.space.floor.building.name } : null,
    }));
  }

  /**
   * Get top 5 recent work orders with lightweight formatted structure.
   * @returns {Promise<Array>}
   */
  async getRecentWorkOrders() {
    const workOrders = await dashboardRepository.getRecentWorkOrders();
    return workOrders.map((wo) => ({
      id: wo.id,
      code: wo.code,
      status: wo.status,
      priority: wo.priority,
      createdAt: wo.createdAt,
      issueNumber: wo.issue ? wo.issue.issueNumber : null,
      issueTitle: wo.issue ? wo.issue.title : null,
      maintenanceDepartment: wo.maintenanceDepartment ? wo.maintenanceDepartment.name : null,
    }));
  }
}

export default new DashboardService();
