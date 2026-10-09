/**
 * @file campus.service.js
 * @description Business logic layer for single Campus management.
 */

import campusRepository from "../repositories/campus/campus.repository.js";
import { ApiError } from "../utils/apiError.js";

export class CampusService {
  /**
   * Retrieves the single active campus configuration.
   * @returns {Promise<Object>}
   */
  async getCampus() {
    const campus = await campusRepository.findCampus();
    if (!campus) {
      throw ApiError.notFound("Campus configuration not found. Please ensure database is seeded.");
    }
    return campus;
  }

  /**
   * Updates the single active campus configuration.
   * @param {Object} updatePayload
   * @returns {Promise<Object>}
   */
  async updateCampus(updatePayload) {
    const campusExists = await campusRepository.exists();
    if (!campusExists) {
      throw ApiError.notFound("Campus configuration not found. Please ensure database is seeded before updating.");
    }

    const updatedCampus = await campusRepository.updateCampus(updatePayload);
    return updatedCampus;
  }
}

export default new CampusService();
