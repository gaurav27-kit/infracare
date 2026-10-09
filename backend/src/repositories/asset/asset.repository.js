/**
 * @file asset.repository.js
 * @description Data access layer for Asset entity using Prisma Client with select optimizations.
 */

import prisma from "../../config/prisma.js";

const DEFAULT_ASSET_SELECT = {
  id: true,
  spaceId: true,
  categoryId: true,
  name: true,
  code: true,
  serialNumber: true,
  qrCode: true,
  status: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  category: {
    select: {
      id: true,
      name: true,
      description: true,
    },
  },
  space: {
    select: {
      id: true,
      name: true,
      code: true,
      floor: {
        select: {
          id: true,
          name: true,
          level: true,
          building: {
            select: {
              id: true,
              name: true,
              code: true,
            },
          },
        },
      },
    },
  },
};

export class AssetRepository {
  /**
   * Find all active assets with pagination, search, filters, and multi-level sorting.
   * Default sorting: Building -> Floor Level -> Space Name -> Asset Name
   * @param {Object} queryOptions
   * @param {number} [queryOptions.page=1]
   * @param {number} [queryOptions.limit=10]
   * @param {string} [queryOptions.search]
   * @param {string} [queryOptions.spaceId]
   * @param {string} [queryOptions.categoryId]
   * @param {string} [queryOptions.status]
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async findAll({ page = 1, limit = 10, search, spaceId, categoryId, status } = {}) {
    const pageNum = Math.max(1, parseInt(page, 10) || 1);
    const limitNum = Math.max(1, parseInt(limit, 10) || 10);
    const skip = (pageNum - 1) * limitNum;

    const where = { deletedAt: null };

    if (spaceId) {
      where.spaceId = spaceId;
    }

    if (categoryId) {
      where.categoryId = categoryId;
    }

    if (status) {
      where.status = status;
    }

    if (search) {
      where.OR = [
        { name: { contains: search, mode: "insensitive" } },
        { code: { contains: search, mode: "insensitive" } },
      ];
    }

    const [data, total] = await Promise.all([
      prisma.asset.findMany({
        where,
        skip,
        take: limitNum,
        select: DEFAULT_ASSET_SELECT,
        orderBy: [
          { space: { floor: { building: { name: "asc" } } } },
          { space: { floor: { level: "asc" } } },
          { space: { name: "asc" } },
          { name: "asc" },
        ],
      }),
      prisma.asset.count({ where }),
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
   * Find active asset by ID.
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async findById(id) {
    if (!id) return null;
    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
    if (!isUuid) return null;
    return prisma.asset.findFirst({
      where: { id, deletedAt: null },
      select: DEFAULT_ASSET_SELECT,
    });
  }

  /**
   * Find active asset by unique asset code.
   * @param {string} code
   * @returns {Promise<Object|null>}
   */
  async findByCode(code) {
    return prisma.asset.findFirst({
      where: { code, deletedAt: null },
      select: DEFAULT_ASSET_SELECT,
    });
  }

  /**
   * Find active asset by spaceId and asset name.
   * @param {string} spaceId
   * @param {string} name
   * @returns {Promise<Object|null>}
   */
  async findByName(spaceId, name) {
    return prisma.asset.findFirst({
      where: { spaceId, name, deletedAt: null },
      select: DEFAULT_ASSET_SELECT,
    });
  }

  /**
   * Find active asset by QR code.
   * @param {string} qrCode
   * @returns {Promise<Object|null>}
   */
  async findByQrCode(qrCode) {
    return prisma.asset.findFirst({
      where: { qrCode, deletedAt: null },
      select: DEFAULT_ASSET_SELECT,
    });
  }

  /**
   * Find active assets belonging to a space.
   * @param {string} spaceId
   * @returns {Promise<Array>}
   */
  async findBySpace(spaceId) {
    return prisma.asset.findMany({
      where: { spaceId, deletedAt: null },
      select: DEFAULT_ASSET_SELECT,
      orderBy: [
        { space: { floor: { building: { name: "asc" } } } },
        { space: { floor: { level: "asc" } } },
        { space: { name: "asc" } },
        { name: "asc" },
      ],
    });
  }

  /**
   * Create a new asset record.
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async create(data) {
    return prisma.asset.create({
      data,
      select: DEFAULT_ASSET_SELECT,
    });
  }

  /**
   * Update an existing asset record by ID.
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async update(id, data) {
    return prisma.asset.update({
      where: { id },
      data,
      select: DEFAULT_ASSET_SELECT,
    });
  }

  /**
   * Soft-delete an asset record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async delete(id) {
    return prisma.asset.update({
      where: { id },
      data: { deletedAt: new Date() },
      select: DEFAULT_ASSET_SELECT,
    });
  }
}

export default new AssetRepository();
