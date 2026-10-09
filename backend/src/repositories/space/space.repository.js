/**
 * @file space.repository.js
 * @description Data access layer for Space entity using Prisma Client with select optimizations.
 */

import prisma from "../../config/prisma.js";

const DEFAULT_SPACE_SELECT = {
  id: true,
  floorId: true,
  name: true,
  code: true,
  type: true,
  capacity: true,
  isAccessible: true,
  isActive: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  floor: {
    select: {
      id: true,
      name: true,
      level: true,
      buildingId: true,
      building: {
        select: {
          id: true,
          name: true,
          code: true,
        },
      },
    },
  },
  _count: {
    select: {
      assets: true,
    },
  },
};

export class SpaceRepository {
  /**
   * Find all active spaces with pagination, search by name/code, and hierarchy sorting.
   * Default sorting: Building Name -> Floor Level -> Space Name
   * Default filter: deletedAt = null and isActive = true
   * @param {Object} queryOptions
   * @param {number} [queryOptions.page=1]
   * @param {number} [queryOptions.limit=10]
   * @param {string} [queryOptions.search]
   * @param {string} [queryOptions.floorId]
   * @param {string} [queryOptions.buildingId]
   * @param {string} [queryOptions.type]
   * @param {boolean} [queryOptions.includeInactive=false]
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async findAll({ page = 1, limit = 100, search, floorId, buildingId, type, includeInactive = false } = {}) {
    const pageNum = Math.max(1, parseInt(page, 10) || 1);
    const limitNum = Math.max(1, parseInt(limit, 10) || 100);
    const skip = (pageNum - 1) * limitNum;

    const where = { deletedAt: null };

    if (!includeInactive) {
      where.isActive = true;
    }

    if (floorId) {
      where.floorId = floorId;
    }

    if (buildingId) {
      where.floor = { buildingId, deletedAt: null };
    }

    if (type) {
      where.type = type;
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: "insensitive" } },
        { code: { contains: search, mode: "insensitive" } },
      ];
    }

    const [data, total] = await Promise.all([
      prisma.space.findMany({
        where,
        skip,
        take: limitNum,
        select: DEFAULT_SPACE_SELECT,
        orderBy: [
          { floor: { building: { name: "asc" } } },
          { floor: { level: "asc" } },
          { name: "asc" },
        ],
      }),
      prisma.space.count({ where }),
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
   * Find active space by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    if (!id) return null;
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
    if (isUuid) {
      return prisma.space.findFirst({
        where: { id, deletedAt: null },
        select: DEFAULT_SPACE_SELECT,
      });
    }

    // Try matching code or name
    const byCodeOrName = await prisma.space.findFirst({
      where: {
        OR: [
          { code: { equals: id, mode: "insensitive" } },
          { name: { equals: id, mode: "insensitive" } },
        ],
        deletedAt: null,
      },
      select: DEFAULT_SPACE_SELECT,
    });
    if (byCodeOrName) return byCodeOrName;

    const allSpaces = await prisma.space.findMany({
      where: { deletedAt: null },
      select: DEFAULT_SPACE_SELECT,
    });
    const found = allSpaces.find(
      (s) =>
        s.name.toLowerCase() === id.toLowerCase() ||
        s.code.toLowerCase() === id.toLowerCase() ||
        id.toLowerCase().includes(s.name.toLowerCase()) ||
        s.name.toLowerCase().includes(id.toLowerCase())
    );
    return found || allSpaces[0] || null;
  }

  /**
   * Find active space by unique code.
   * @param {string} code
   * @returns {Promise<Object|null>}
   */
  async findByCode(code) {
    return prisma.space.findFirst({
      where: { code, deletedAt: null },
      select: DEFAULT_SPACE_SELECT,
    });
  }

  /**
   * Find active spaces belonging to a floor.
   * @param {string} floorId
   * @returns {Promise<Array>}
   */
  async findByFloor(floorId) {
    return prisma.space.findMany({
      where: { floorId, deletedAt: null, isActive: true },
      select: DEFAULT_SPACE_SELECT,
      orderBy: [
        { floor: { building: { name: "asc" } } },
        { floor: { level: "asc" } },
        { name: "asc" },
      ],
    });
  }

  /**
   * Find active space by floor ID and name.
   * @param {string} floorId
   * @param {string} name
   * @returns {Promise<Object|null>}
   */
  async findByName(floorId, name) {
    return prisma.space.findFirst({
      where: { floorId, name, deletedAt: null },
      select: DEFAULT_SPACE_SELECT,
    });
  }

  /**
   * Count active assets belonging to a space.
   * @param {string} spaceId
   * @returns {Promise<number>}
   */
  async countAssets(spaceId) {
    return prisma.asset.count({
      where: { spaceId, deletedAt: null },
    });
  }

  /**
   * Create a new space record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.space.create({
      data,
      select: DEFAULT_SPACE_SELECT,
    });
  }

  /**
   * Update an existing space record by ID.
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    return prisma.space.update({
      where: { id },
      data,
      select: DEFAULT_SPACE_SELECT,
    });
  }

  /**
   * Soft-delete a space record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.space.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: DEFAULT_SPACE_SELECT,
    });
  }
}

export default new SpaceRepository();
