/**
 * @file building.service.js
 * @description Business logic layer for Building entity management.
 */

import buildingRepository from "../repositories/building/building.repository.js";
import campusRepository from "../repositories/campus/campus.repository.js";
import { ApiError } from "../utils/apiError.js";

export class BuildingService {
  /**
   * Retrieve all active buildings.
   * @returns {Promise<Array>}
   */
  async getAllBuildings() {
    return buildingRepository.findAll();
  }

  /**
   * Retrieve a building by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async getBuildingById(id) {
    const building = await buildingRepository.findById(id);
    if (!building) {
      throw ApiError.notFound(`Building with ID ${id} not found`);
    }
    return building;
  }

  /**
   * Create a new building under the single active campus.
   * @param {Object} payload - Building creation data ({ name, code })
   * @returns {Promise<Object>}
   */
  async createBuilding(payload) {
    const { name, code } = payload;

    // Single Campus Requirement: resolve active campus
    const campus = await campusRepository.findCampus();
    if (!campus) {
      throw ApiError.notFound("Campus configuration not found. Please ensure database is seeded.");
    }

    // Business Rule: Prevent duplicate building codes
    const existingCode = await buildingRepository.findByCode(code);
    if (existingCode) {
      throw ApiError.conflict(`Building code '${code}' already exists`);
    }

    // Business Rule: Prevent duplicate building names within the campus
    const existingName = await buildingRepository.findByName(name);
    if (existingName) {
      throw ApiError.conflict(`Building name '${name}' already exists within the campus`);
    }

    return buildingRepository.create({
      name,
      code,
      campusId: campus.id,
    });
  }

  /**
   * Update an existing building record by ID.
   * @param {string} id
   * @param {Object} payload - Fields to update ({ name, code })
   * @returns {Promise<Object>}
   */
  async updateBuilding(id, payload) {
    const building = await buildingRepository.findById(id);
    if (!building) {
      throw ApiError.notFound(`Building with ID ${id} not found`);
    }

    const { name, code } = payload;
    const updateData = {};

    if (code && code !== building.code) {
      const existingCode = await buildingRepository.findByCode(code);
      if (existingCode && existingCode.id !== id) {
        throw ApiError.conflict(`Building code '${code}' already exists`);
      }
      updateData.code = code;
    }

    if (name && name !== building.name) {
      const existingName = await buildingRepository.findByName(name);
      if (existingName && existingName.id !== id) {
        throw ApiError.conflict(`Building name '${name}' already exists within the campus`);
      }
      updateData.name = name;
    }

    if (Object.keys(updateData).length === 0) {
      return building;
    }

    return buildingRepository.update(id, updateData);
  }

  /**
   * Soft-delete a building record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteBuilding(id) {
    const building = await buildingRepository.findById(id);
    if (!building) {
      throw ApiError.notFound(`Building with ID ${id} not found`);
    }

    await buildingRepository.delete(id);
    return { id, deleted: true };
  }
}

export default new BuildingService();
