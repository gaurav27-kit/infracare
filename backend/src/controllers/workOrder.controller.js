/**
 * @file workOrder.controller.js
 * @description HTTP Controller handling requests for WorkOrder entities.
 */

import workOrderService from "../services/workOrder.service.js";
import { ApiResponse } from "../utils/apiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

/**
 * @route   GET /api/v1/work-orders
 * @desc    Get paginated active work order entities
 * @access  Public / Authenticated
 */
export const getWorkOrders = asyncHandler(async (req, res) => {
  const { data, meta } = await workOrderService.getAllWorkOrders(req.query);
  return ApiResponse.success(res, "Work orders retrieved successfully", data, 200, meta);
});

/**
 * @route   GET /api/v1/work-orders/:id
 * @desc    Get work order details by ID
 * @access  Public / Authenticated
 */
export const getWorkOrderById = asyncHandler(async (req, res) => {
  const workOrder = await workOrderService.getWorkOrderById(req.params.id);
  return ApiResponse.success(res, "Work order details retrieved successfully", workOrder);
});

/**
 * @route   POST /api/v1/work-orders
 * @desc    Create a new work order entity
 * @access  Public / Authenticated
 */
export const createWorkOrder = asyncHandler(async (req, res) => {
  const newWorkOrder = await workOrderService.createWorkOrder(req.body);
  return ApiResponse.success(res, "Work order created successfully", newWorkOrder, 201);
});

/**
 * @route   PUT /api/v1/work-orders/:id
 * @desc    Update work order details by ID
 * @access  Public / Authenticated
 */
export const updateWorkOrder = asyncHandler(async (req, res) => {
  const updatedWorkOrder = await workOrderService.updateWorkOrder(req.params.id, req.body);
  return ApiResponse.success(res, "Work order updated successfully", updatedWorkOrder);
});

/**
 * @route   DELETE /api/v1/work-orders/:id
 * @desc    Soft-delete work order by ID
 * @access  Public / Authenticated
 */
export const deleteWorkOrder = asyncHandler(async (req, res) => {
  const result = await workOrderService.deleteWorkOrder(req.params.id);
  return ApiResponse.success(res, "Work order deleted successfully", result);
});
