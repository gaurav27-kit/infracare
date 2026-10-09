/**
 * @file asset.service.js
 * @description Business logic layer for Asset entity management with audit logging.
 */

import assetRepository from "../repositories/asset/asset.repository.js";
import spaceRepository from "../repositories/space/space.repository.js";
import prisma from "../config/prisma.js";
import { ApiError } from "../utils/apiError.js";
import { AssetStatus } from "../types/enums.js";
import logger from "../utils/logger.js";

export class AssetService {
  /**
   * Retrieve active assets with optional filters.
   * @param {Object} queryParams
   * @returns {Promise<{ data: Array, meta: Object }>}
   */
  async getAllAssets(queryParams = {}) {
    return assetRepository.findAll(queryParams);
  }

  /**
   * Retrieve an asset by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async getAssetById(id) {
    const asset = await assetRepository.findById(id);
    if (!asset) {
      throw ApiError.notFound(`Asset with ID ${id} not found`);
    }
    return asset;
  }

  /**
   * Create a new asset record under a space and category.
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async createAsset(payload) {
    const { spaceId, assetCategoryId, categoryId, name, code, serialNumber, qrCode, status } = payload;
    const resolvedCategoryId = categoryId || assetCategoryId;

    // Business Rule: Verify active Space exists
    const space = await spaceRepository.findById(spaceId);
    if (!space) {
      throw ApiError.notFound(`Space with ID ${spaceId} not found`);
    }

    // Business Rule: Verify active AssetCategory exists
    const category = await prisma.assetCategory.findFirst({
      where: { id: resolvedCategoryId, deletedAt: null },
    });
    if (!category) {
      throw ApiError.notFound(`Asset category with ID ${resolvedCategoryId} not found`);
    }

    // Business Rule: Validate AssetStatus enum
    if (status && !Object.values(AssetStatus).includes(status)) {
      throw ApiError.badRequest(`Invalid AssetStatus: '${status}'`);
    }

    // Business Rule: Asset code must be unique across the campus
    if (code) {
      const existingCode = await assetRepository.findByCode(code);
      if (existingCode) {
        throw ApiError.conflict(`Asset code '${code}' already exists`);
      }
    }

    // Business Rule: Prevent duplicate Asset name within the same Space
    const existingName = await assetRepository.findByName(spaceId, name);
    if (existingName) {
      throw ApiError.conflict(`Asset name '${name}' already exists in this space`);
    }

    // Business Rule: Prevent duplicate QR code if provided
    if (qrCode) {
      const existingQr = await assetRepository.findByQrCode(qrCode);
      if (existingQr) {
        throw ApiError.conflict(`QR code '${qrCode}' already exists`);
      }
    }

    const createData = {
      spaceId,
      categoryId: resolvedCategoryId,
      name,
      code,
      ...(serialNumber && { serialNumber }),
      ...(qrCode && { qrCode }),
      ...(status && { status }),
    };

    const newAsset = await assetRepository.create(createData);

    // Audit Logging
    logger.info("Asset Created", {
      assetId: newAsset.id,
      assetCode: newAsset.code,
      assetName: newAsset.name,
      timestamp: new Date().toISOString(),
    });

    return newAsset;
  }

  /**
   * Update an existing asset record by ID.
   * @param {string} id
   * @param {Object} payload
   * @returns {Promise<Object>}
   */
  async updateAsset(id, payload) {
    const asset = await assetRepository.findById(id);
    if (!asset) {
      throw ApiError.notFound(`Asset with ID ${id} not found`);
    }

    const { spaceId, assetCategoryId, categoryId, name, code, serialNumber, qrCode, status } = payload;
    const resolvedCategoryId = categoryId || assetCategoryId;
    const targetSpaceId = spaceId || asset.spaceId;
    const updateData = {};

    if (spaceId && spaceId !== asset.spaceId) {
      const targetSpace = await spaceRepository.findById(spaceId);
      if (!targetSpace) {
        throw ApiError.notFound(`Space with ID ${spaceId} not found`);
      }
      updateData.spaceId = spaceId;
    }

    if (resolvedCategoryId && resolvedCategoryId !== asset.categoryId) {
      const targetCategory = await prisma.assetCategory.findFirst({
        where: { id: resolvedCategoryId, deletedAt: null },
      });
      if (!targetCategory) {
        throw ApiError.notFound(`Asset category with ID ${resolvedCategoryId} not found`);
      }
      updateData.categoryId = resolvedCategoryId;
    }

    if (status !== undefined && status !== asset.status) {
      if (!Object.values(AssetStatus).includes(status)) {
        throw ApiError.badRequest(`Invalid AssetStatus: '${status}'`);
      }
      updateData.status = status;
    }

    if (code && code !== asset.code) {
      const existingCode = await assetRepository.findByCode(code);
      if (existingCode && existingCode.id !== id) {
        throw ApiError.conflict(`Asset code '${code}' already exists`);
      }
      updateData.code = code;
    }

    if ((name && name !== asset.name) || spaceId) {
      const targetName = name || asset.name;
      const existingName = await assetRepository.findByName(targetSpaceId, targetName);
      if (existingName && existingName.id !== id) {
        throw ApiError.conflict(`Asset name '${targetName}' already exists in this space`);
      }
      if (name) updateData.name = name;
    }

    if (qrCode !== undefined && qrCode !== asset.qrCode) {
      if (qrCode) {
        const existingQr = await assetRepository.findByQrCode(qrCode);
        if (existingQr && existingQr.id !== id) {
          throw ApiError.conflict(`QR code '${qrCode}' already exists`);
        }
      }
      updateData.qrCode = qrCode;
    }

    if (serialNumber !== undefined) {
      updateData.serialNumber = serialNumber;
    }

    if (Object.keys(updateData).length === 0) {
      return asset;
    }

    const updatedAsset = await assetRepository.update(id, updateData);

    // Audit Logging
    logger.info("Asset Updated", {
      assetId: updatedAsset.id,
      assetCode: updatedAsset.code,
      assetName: updatedAsset.name,
      timestamp: new Date().toISOString(),
    });

    return updatedAsset;
  }

  /**
   * Soft-delete an asset record by ID.
   * @param {string} id
   * @returns {Promise<Object>}
   */
  async deleteAsset(id) {
    const asset = await assetRepository.findById(id);
    if (!asset) {
      throw ApiError.notFound(`Asset with ID ${id} not found`);
    }

    await assetRepository.delete(id);

    // Audit Logging
    logger.info("Asset Soft Deleted", {
      assetId: asset.id,
      assetCode: asset.code,
      assetName: asset.name,
      timestamp: new Date().toISOString(),
    });

    return { id, deleted: true };
  }
}

export default new AssetService();
