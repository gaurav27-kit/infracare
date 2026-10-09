/**
 * @file floor.repository.js
 * @description Data access layer for Floor entity using Prisma Client.
 */

import prisma from "../../config/prisma.js";

export class FloorRepository {
  /**
   * Find all active floors with pagination, search, and building filter.
   * @param {Object} queryOptions
   * @param {number} [queryOptions.page=1]
   * @param {number} [queryOptions.limit=10]
   * @param {string} [queryOptions.search]
   * @param {string} [queryOptions.buildingId]
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async findAll({ page = 1, limit = 10, search, buildingId } = {}) {
    const pageNum = Math.max(1, parseInt(page, 10) || 1);
    const limitNum = Math.max(1, parseInt(limit, 10) || 10);
    const skip = (pageNum - 1) * limitNum;

    const where = { deletedAt: null };

    if (buildingId) {
      const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(buildingId);
      if (isUuid) {
        where.buildingId = buildingId;
      } else {
        where.building = {
          OR: [
            { code: { equals: buildingId, mode: "insensitive" } },
            { name: { contains: buildingId, mode: "insensitive" } },
          ],
        };
      }
    }

    if (search) {
      where.name = { contains: search, mode: "insensitive" };
    }

    const [data, total] = await Promise.all([
      prisma.floor.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          building: {
            select: { id: true, name: true, code: true },
          },
          _count: {
            select: { spaces: true },
          },
        },
        orderBy: [{ building: { name: "asc" } }, { level: "asc" }],
      }),
      prisma.floor.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limitNum) || 1;

    return {
      data,
      meta: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages,
        hasNext: pageNum < totalPages,
        hasPrevious: pageNum > 1,
      },
    };
  }

  /**
   * Find active floor by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    return prisma.floor.findFirst({
      where: { id, deletedAt: null },
      include: {
        building: {
          select: { id: true, name: true, code: true },
        },
        _count: {
          select: { spaces: true },
        },
      },
    });
  }

  /**
   * Find active floors for a specific building.
   * @param {string} buildingId
   * @returns {Promise<Array>}
   */
  async findByBuilding(buildingId) {
    return prisma.floor.findMany({
      where: { buildingId, deletedAt: null },
      include: {
        building: {
          select: { id: true, name: true, code: true },
        },
        _count: {
          select: { spaces: true },
        },
      },
      orderBy: { level: "asc" },
    });
  }

  /**
   * Find active floor by building ID and level integer.
   * @param {string} buildingId
   * @param {number} level
   * @returns {Promise<Object|null>}
   */
  async findByLevel(buildingId, level) {
    return prisma.floor.findFirst({
      where: { buildingId, level: parseInt(level, 10), deletedAt: null },
    });
  }

  /**
   * Find active floor by building ID and floor name.
   * @param {string} buildingId
   * @param {string} name
   * @returns {Promise<Object|null>}
   */
  async findByName(buildingId, name) {
    return prisma.floor.findFirst({
      where: { buildingId, name, deletedAt: null },
    });
  }

  /**
   * Count active spaces belonging to a floor.
   * @param {string} floorId
   * @returns {Promise<number>}
   */
  async countSpaces(floorId) {
    return prisma.space.count({
      where: { floorId, deletedAt: null },
    });
  }

  /**
   * Create a new floor record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.floor.create({
      data,
      include: {
        building: {
          select: { id: true, name: true, code: true },
        },
      },
    });
  }

  /**
   * Update an existing floor record by ID.
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    return prisma.floor.update({
      where: { id },
      data,
      include: {
        building: {
          select: { id: true, name: true, code: true },
        },
      },
    });
  }

  /**
   * Soft-delete a floor record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.floor.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}

export default new FloorRepository();
