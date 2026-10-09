/**
 * @file space.service.js
 * @description Business logic layer for Space entity management with audit logging.
 */

import spaceRepository from "../repositories/space/space.repository.js";
import floorRepository from "../repositories/floor/floor.repository.js";
import { ApiError } from "../utils/apiError.js";
import { SpaceType } from "../types/enums.js";
import logger from "../utils/logger.js";

export class SpaceService {
  /**
   * Retrieve active spaces with optional filters.
   * @param {Object} queryParams
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async getAllSpaces(queryParams = {}) {
    return spaceRepository.findAll(queryParams);
  }

  /**
   * Retrieve a space by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async getSpaceById(id) {
    const space = await spaceRepository.findById(id);
    if (!space) {
      throw ApiError.notFound(`Space with ID ${id} not found`);
    }
    return space;
  }

  /**
   * Create a new space record under a floor.
   * @param {Object} payload - { floorId, name, code, type, capacity, isAccessible, isActive }
   * @returns {Promise<Object>}
   */
  async createSpace(payload) {
    const { floorId, name, code, type, capacity, isAccessible, isActive } = payload;

    // Business Rule: Verify active Floor exists
    const floor = await floorRepository.findById(floorId);
    if (!floor) {
      throw ApiError.notFound(`Floor with ID ${floorId} not found`);
    }

    // Business Rule: Validate SpaceType enum
    if (type && !Object.values(SpaceType).includes(type)) {
      throw ApiError.badRequest(`Invalid SpaceType: '${type}'`);
    }

    // Business Rule: Space code must be unique across the campus
    if (code) {
      const existingCode = await spaceRepository.findByCode(code);
      if (existingCode) {
        throw ApiError.conflict(`Space code '${code}' already exists`);
      }
    }

    // Business Rule: Prevent duplicate Space name within the same Floor
    const existingName = await spaceRepository.findByName(floorId, name);
    if (existingName) {
      throw ApiError.conflict(`Space name '${name}' already exists on this floor`);
    }

    const createData = {
      floorId,
      name,
      code,
      type,
      ...(capacity !== undefined && { capacity: capacity === null ? null : parseInt(capacity, 10) }),
      ...(isAccessible !== undefined && { isAccessible }),
      ...(isActive !== undefined && { isActive }),
    };

    const newSpace = await spaceRepository.create(createData);

    // Audit Logging
    logger.info("Space Created", {
      spaceId: newSpace.id,
      spaceCode: newSpace.code,
      spaceName: newSpace.name,
      timestamp: new Date().toISOString(),
    });

    return newSpace;
  }

  /**
   * Update an existing space record by ID.
   * @param {string} id
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async updateSpace(id, payload) {
    const space = await spaceRepository.findById(id);
    if (!space) {
      throw ApiError.notFound(`Space with ID ${id} not found`);
    }

    const { floorId, name, code, type, capacity, isAccessible, isActive } = payload;
    const targetFloorId = floorId || space.floorId;
    const updateData = {};

    if (floorId && floorId !== space.floorId) {
      const targetFloor = await floorRepository.findById(floorId);
      if (!targetFloor) {
        throw ApiError.notFound(`Floor with ID ${floorId} not found`);
      }
      updateData.floorId = floorId;
    }

    if (code && code !== space.code) {
      const existingCode = await spaceRepository.findByCode(code);
      if (existingCode && existingCode.id !== id) {
        throw ApiError.conflict(`Space code '${code}' already exists`);
      }
      updateData.code = code;
    }

    if (type !== undefined && type !== space.type) {
      if (!Object.values(SpaceType).includes(type)) {
        throw ApiError.badRequest(`Invalid SpaceType: '${type}'`);
      }
      updateData.type = type;
    }

    if ((name && name !== space.name) || floorId) {
      const targetName = name || space.name;
      const existingName = await spaceRepository.findByName(targetFloorId, targetName);
      if (existingName && existingName.id !== id) {
        throw ApiError.conflict(`Space name '${targetName}' already exists on this floor`);
      }
      if (name) updateData.name = name;
    }

    if (capacity !== undefined) {
      updateData.capacity = capacity === null ? null : parseInt(capacity, 10);
    }

    if (isAccessible !== undefined) {
      updateData.isAccessible = isAccessible;
    }

    if (isActive !== undefined) {
      updateData.isActive = isActive;
    }

    if (Object.keys(updateData).length === 0) {
      return space;
    }

    const updatedSpace = await spaceRepository.update(id, updateData);

    // Audit Logging
    logger.info("Space Updated", {
      spaceId: updatedSpace.id,
      spaceCode: updatedSpace.code,
      spaceName: updatedSpace.name,
      timestamp: new Date().toISOString(),
    });

    return updatedSpace;
  }

  /**
   * Soft-delete a space record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteSpace(id) {
    const space = await spaceRepository.findById(id);
    if (!space) {
      throw ApiError.notFound(`Space with ID ${id} not found`);
    }

    // Business Rule: Prevent deleting Spaces containing active Assets
    const assetsCount = await spaceRepository.countAssets(id);
    if (assetsCount > 0) {
      throw ApiError.conflict("Cannot delete space because it contains assets.");
    }

    await spaceRepository.delete(id);

    // Audit Logging
    logger.info("Space Soft Deleted", {
      spaceId: space.id,
      spaceCode: space.code,
      spaceName: space.name,
      timestamp: new Date().toISOString(),
    });

    return { id, deleted: true };
  }
}

export default new SpaceService();
