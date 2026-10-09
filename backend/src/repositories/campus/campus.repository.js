/**
 * @file campus.repository.js
 * @description Data access layer for single Campus configuration entity.
 * In Version 1, the repository internally resolves the single Campus record without requiring IDs from callers.
 */

import prisma from "../../config/prisma.js";

export class CampusRepository {
  /**
   * Find the single active campus record.
   * @returns {Promise<Object|null>}
   */
  async findCampus() {
    return prisma.campus.findFirst({
      where: { deletedAt: null },
      include: {
        _count: {
          select: { buildings: true },
        },
      },
    });
  }

  /**
   * Check if a single campus record exists.
   * @returns {Promise<boolean>}
   */
  async exists() {
    const count = await prisma.campus.count({
      where: { deletedAt: null },
    });
    return count > 0;
  }

  /**
   * Update the single active campus record.
   * Retrieves the single campus internally before performing update.
   * @param {Object} updateData
   * @returns {Promise<Object>}
   */
  async updateCampus(updateData) {
    const currentCampus = await this.findCampus();
    if (!currentCampus) {
      throw new Error("Campus record not found to update");
    }

    return prisma.campus.update({
      where: { id: currentCampus.id },
      data: updateData,
    });
  }
}

export default new CampusRepository();
