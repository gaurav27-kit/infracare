/**
 * @file building.repository.js
 * @description Data access layer for Building entity using Prisma Client.
 */

import prisma from "../../config/prisma.js";

export class BuildingRepository {
  /**
   * Find all active buildings.
   * @returns {Promise<Array>}
   */
  async findAll() {
    return prisma.building.findMany({
      where: { deletedAt: null },
      include: {
        campus: {
          select: { id: true, name: true, code: true },
        },
        _count: {
          select: { floors: true },
        },
      },
      orderBy: [{ name: "asc" }],
    });
  }

  /**
   * Find active building by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    return prisma.building.findFirst({
      where: { id, deletedAt: null },
      include: {
        campus: {
          select: { id: true, name: true, code: true },
        },
        _count: {
          select: { floors: true },
        },
      },
    });
  }

  /**
   * Find active building by unique building code.
   * @param {string} code
   * @returns {Promise<Object|null>}
   */
  async findByCode(code) {
    return prisma.building.findFirst({
      where: { code, deletedAt: null },
    });
  }

  /**
   * Find active building by name within the campus.
   * @param {string} name
   * @returns {Promise<Object|null>}
   */
  async findByName(name) {
    return prisma.building.findFirst({
      where: { name, deletedAt: null },
    });
  }

  /**
   * Create a new building record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.building.create({
      data,
      include: {
        campus: {
          select: { id: true, name: true, code: true },
        },
      },
    });
  }

  /**
   * Update an existing building record by ID.
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    return prisma.building.update({
      where: { id },
      data,
      include: {
        campus: {
          select: { id: true, name: true, code: true },
        },
      },
    });
  }

  /**
   * Soft-delete a building record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.building.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}

export default new BuildingRepository();
