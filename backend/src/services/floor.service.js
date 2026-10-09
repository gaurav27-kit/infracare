/**
 * @file floor.service.js
 * @description Business logic layer for Floor entity management.
 */

import floorRepository from "../repositories/floor/floor.repository.js";
import buildingRepository from "../repositories/building/building.repository.js";
import { ApiError } from "../utils/apiError.js";

export class FloorService {
  /**
   * Retrieve active floors with optional pagination, search, and building filter.
   * @param {Object} queryParams
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async getAllFloors(queryParams = {}) {
    return floorRepository.findAll(queryParams);
  }

  /**
   * Retrieve a floor by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async getFloorById(id) {
    const floor = await floorRepository.findById(id);
    if (!floor) {
      throw ApiError.notFound(`Floor with ID ${id} not found`);
    }
    return floor;
  }

  /**
   * Create a new floor record under a building.
   * @param {Object} payload - { buildingId, name, level }
   * @returns {Promise<Object>}
   */
  async createFloor(payload) {
    const { buildingId, name, level } = payload;

    // Business Rule: Verify target Building exists and is active
    const building = await buildingRepository.findById(buildingId);
    if (!building) {
      throw ApiError.notFound(`Building with ID ${buildingId} not found`);
    }

    // Business Rule: Prevent duplicate floor levels within the same Building
    const existingLevel = await floorRepository.findByLevel(buildingId, level);
    if (existingLevel) {
      throw ApiError.conflict(`Floor level ${level} already exists in this building`);
    }

    // Business Rule: Prevent duplicate floor names within the same Building
    const existingName = await floorRepository.findByName(buildingId, name);
    if (existingName) {
      throw ApiError.conflict(`Floor name '${name}' already exists in this building`);
    }

    return floorRepository.create({
      buildingId,
      name,
      level: parseInt(level, 10),
    });
  }

  /**
   * Update an existing floor record by ID.
   * @param {string} id
   * @param {Object} payload - { buildingId, name, level }
   * @returns {Promise<Object>}
   */
  async updateFloor(id, payload) {
    const floor = await floorRepository.findById(id);
    if (!floor) {
      throw ApiError.notFound(`Floor with ID ${id} not found`);
    }

    const { buildingId, name, level } = payload;
    const targetBuildingId = buildingId || floor.buildingId;
    const updateData = {};

    if (buildingId && buildingId !== floor.buildingId) {
      const targetBuilding = await buildingRepository.findById(buildingId);
      if (!targetBuilding) {
        throw ApiError.notFound(`Building with ID ${buildingId} not found`);
      }
      updateData.buildingId = buildingId;
    }

    if (level !== undefined && (level !== floor.level || buildingId)) {
      const parsedLevel = parseInt(level, 10);
      const existingLevel = await floorRepository.findByLevel(targetBuildingId, parsedLevel);
      if (existingLevel && existingLevel.id !== id) {
        throw ApiError.conflict(`Floor level ${parsedLevel} already exists in this building`);
      }
      updateData.level = parsedLevel;
    }

    if (name !== undefined && (name !== floor.name || buildingId)) {
      const existingName = await floorRepository.findByName(targetBuildingId, name);
      if (existingName && existingName.id !== id) {
        throw ApiError.conflict(`Floor name '${name}' already exists in this building`);
      }
      updateData.name = name;
    }

    if (Object.keys(updateData).length === 0) {
      return floor;
    }

    return floorRepository.update(id, updateData);
  }

  /**
   * Soft-delete a floor record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteFloor(id) {
    const floor = await floorRepository.findById(id);
    if (!floor) {
      throw ApiError.notFound(`Floor with ID ${id} not found`);
    }

    // Business Rule: Prevent deleting Floors containing active Spaces
    const spacesCount = await floorRepository.countSpaces(id);
    if (spacesCount > 0) {
      throw ApiError.conflict("Cannot delete floor because it contains spaces.");
    }

    await floorRepository.delete(id);
    return { id, deleted: true };
  }
}

export default new FloorService();
