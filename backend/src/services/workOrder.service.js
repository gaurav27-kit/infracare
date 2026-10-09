/**
 * @file workOrder.service.js
 * @description Business logic layer for WorkOrder entity management with validation and audit logging.
 */

import workOrderRepository from "../repositories/workOrder/workOrder.repository.js";
import issueRepository from "../repositories/issue/issue.repository.js";
import prisma from "../config/prisma.js";
import { ApiError } from "../utils/apiError.js";
import { WorkOrderPriority, WorkOrderStatus } from "../types/enums.js";
import logger from "../utils/logger.js";

export class WorkOrderService {
  /**
   * Auto-generate next sequential readable work order code (WO-0001, WO-0002, etc.).
   * @returns {Promise<string>}
   */
  async generateWorkOrderCode() {
    const latest = await workOrderRepository.findLatest();
    let nextCount = 1;

    if (latest && latest.code) {
      const match = latest.code.match(/^WO-(\d+)$/);
      if (match) {
        nextCount = parseInt(match[1], 10) + 1;
      }
    }

    let candidate = `WO-${String(nextCount).padStart(4, "0")}`;
    let existing = await workOrderRepository.findByCode(candidate);

    while (existing) {
      nextCount++;
      candidate = `WO-${String(nextCount).padStart(4, "0")}`;
      existing = await workOrderRepository.findByCode(candidate);
    }

    return candidate;
  }

  /**
   * Retrieve active work orders with optional query parameters.
   * @param {Object} queryParams
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async getAllWorkOrders(queryParams = {}) {
    return workOrderRepository.findAll(queryParams);
  }

  /**
   * Retrieve a work order by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async getWorkOrderById(id) {
    const workOrder = await workOrderRepository.findById(id);
    if (!workOrder) {
      throw ApiError.notFound(`WorkOrder with ID ${id} not found`);
    }
    return workOrder;
  }

  /**
   * Create a new work order record.
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async createWorkOrder(payload) {
    const {
      issueId,
      maintenanceDepartmentId,
      assignedToExternalUserId,
      priority = WorkOrderPriority.MEDIUM,
      status = WorkOrderStatus.SCHEDULED,
      scheduledStart,
      scheduledEnd,
      actualStart,
      actualEnd,
      cost,
      resolutionNotes,
    } = payload;

    // Business Rule 1: Validate active Issue exists
    const issue = await issueRepository.findById(issueId);
    if (!issue) {
      throw ApiError.notFound(`Issue with ID ${issueId} not found`);
    }

    // Business Rule 2: Validate active Maintenance Department exists
    const dept = await prisma.maintenanceDepartment.findFirst({
      where: { id: maintenanceDepartmentId, deletedAt: null },
    });
    if (!dept) {
      throw ApiError.notFound(`Maintenance department with ID ${maintenanceDepartmentId} not found`);
    }

    // Business Rule 3: Validate Enums
    const resolvedPriority = priority || WorkOrderPriority.MEDIUM;
    if (!Object.values(WorkOrderPriority).includes(resolvedPriority)) {
      throw ApiError.badRequest(`Invalid WorkOrderPriority: '${resolvedPriority}'`);
    }

    const resolvedStatus = status || WorkOrderStatus.SCHEDULED;
    if (!Object.values(WorkOrderStatus).includes(resolvedStatus)) {
      throw ApiError.badRequest(`Invalid WorkOrderStatus: '${resolvedStatus}'`);
    }

    // Auto-generate code
    const code = await this.generateWorkOrderCode();

    const createData = {
      code,
      issueId,
      maintenanceDepartmentId,
      priority: resolvedPriority,
      status: resolvedStatus,
      ...(assignedToExternalUserId && { assignedToExternalUserId }),
      ...(scheduledStart && { scheduledStart: new Date(scheduledStart) }),
      ...(scheduledEnd && { scheduledEnd: new Date(scheduledEnd) }),
      ...(actualStart && { actualStart: new Date(actualStart) }),
      ...(actualEnd && { actualEnd: new Date(actualEnd) }),
      ...(cost !== undefined && { cost }),
      ...(resolutionNotes && { resolutionNotes }),
    };

    const newWorkOrder = await workOrderRepository.create(createData);

    // Audit Logging
    logger.info("WorkOrder Created", {
      id: newWorkOrder.id,
      code: newWorkOrder.code,
      timestamp: new Date().toISOString(),
    });

    return newWorkOrder;
  }

  /**
   * Update an existing work order record by ID.
   * @param {string} id
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async updateWorkOrder(id, payload) {
    const workOrder = await workOrderRepository.findById(id);
    if (!workOrder) {
      throw ApiError.notFound(`WorkOrder with ID ${id} not found`);
    }

    const {
      issueId,
      maintenanceDepartmentId,
      assignedToExternalUserId,
      priority,
      status,
      scheduledStart,
      scheduledEnd,
      actualStart,
      actualEnd,
      cost,
      resolutionNotes,
    } = payload;

    const updateData = {};

    if (issueId !== undefined && issueId !== workOrder.issueId) {
      const issue = await issueRepository.findById(issueId);
      if (!issue) {
        throw ApiError.notFound(`Issue with ID ${issueId} not found`);
      }
      updateData.issueId = issueId;
    }

    if (
      maintenanceDepartmentId !== undefined &&
      maintenanceDepartmentId !== workOrder.maintenanceDepartmentId
    ) {
      const dept = await prisma.maintenanceDepartment.findFirst({
        where: { id: maintenanceDepartmentId, deletedAt: null },
      });
      if (!dept) {
        throw ApiError.notFound(`Maintenance department with ID ${maintenanceDepartmentId} not found`);
      }
      updateData.maintenanceDepartmentId = maintenanceDepartmentId;
    }

    if (priority !== undefined) {
      if (!Object.values(WorkOrderPriority).includes(priority)) {
        throw ApiError.badRequest(`Invalid WorkOrderPriority: '${priority}'`);
      }
      updateData.priority = priority;
    }

    if (status !== undefined) {
      if (!Object.values(WorkOrderStatus).includes(status)) {
        throw ApiError.badRequest(`Invalid WorkOrderStatus: '${status}'`);
      }
      updateData.status = status;
    }

    if (assignedToExternalUserId !== undefined) {
      updateData.assignedToExternalUserId = assignedToExternalUserId;
    }

    if (scheduledStart !== undefined) {
      updateData.scheduledStart = scheduledStart ? new Date(scheduledStart) : null;
    }

    if (scheduledEnd !== undefined) {
      updateData.scheduledEnd = scheduledEnd ? new Date(scheduledEnd) : null;
    }

    if (actualStart !== undefined) {
      updateData.actualStart = actualStart ? new Date(actualStart) : null;
    }

    if (actualEnd !== undefined) {
      updateData.actualEnd = actualEnd ? new Date(actualEnd) : null;
    }

    if (cost !== undefined) {
      updateData.cost = cost;
    }

    if (resolutionNotes !== undefined) {
      updateData.resolutionNotes = resolutionNotes;
    }

    if (Object.keys(updateData).length === 0) {
      return workOrder;
    }

    const updatedWorkOrder = await workOrderRepository.update(id, updateData);

    // Audit Logging
    logger.info("WorkOrder Updated", {
      id: updatedWorkOrder.id,
      code: updatedWorkOrder.code,
      timestamp: new Date().toISOString(),
    });

    return updatedWorkOrder;
  }

  /**
   * Soft-delete a work order record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteWorkOrder(id) {
    const workOrder = await workOrderRepository.findById(id);
    if (!workOrder) {
      throw ApiError.notFound(`WorkOrder with ID ${id} not found`);
    }

    await workOrderRepository.delete(id);

    // Audit Logging
    logger.info("WorkOrder Soft Deleted", {
      id: workOrder.id,
      code: workOrder.code,
      timestamp: new Date().toISOString(),
    });

    return { id, deleted: true };
  }
}

export default new WorkOrderService();
