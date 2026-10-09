import request from "supertest";
import app from "../src/app.js";
import assetRepository from "../src/repositories/asset/asset.repository.js";
import spaceRepository from "../src/repositories/space/space.repository.js";
import assetService from "../src/services/asset.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";
import { AssetStatus } from "../src/types/enums.js";

describe("Asset Module Tests", () => {
  const mockBuilding = {
    id: "00000000-0000-4000-8000-000000000000",
    name: "Academic Block A",
    code: "ACAD-BLK-A",
  };

  const mockFloor = {
    id: "11111111-1111-4111-8111-111111111111",
    level: 1,
    name: "Ground Floor",
    buildingId: mockBuilding.id,
    building: mockBuilding,
  };

  const mockSpace = {
    id: "22222222-2222-4222-8222-222222222222",
    floorId: mockFloor.id,
    name: "Central Seminar Hall A1",
    code: "SEM-A1",
    floor: mockFloor,
  };

  const mockCategory = {
    id: "33333333-3333-4333-8333-333333333333",
    name: "IT & Audio/Visual",
    description: "Projectors, displays, audio equipment",
  };

  const mockAsset = {
    id: "44444444-4444-4444-8444-444444444444",
    spaceId: mockSpace.id,
    categoryId: mockCategory.id,
    name: "4K Laser Projection System",
    code: "IT-001",
    serialNumber: "AV-AUD-PROJ-01",
    qrCode: "QR-AV-AUD-PROJ-01",
    status: AssetStatus.OPERATIONAL,
    category: mockCategory,
    space: mockSpace,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Specs ───────────────────────────────────────────────────
  describe("AssetRepository Unit Specs", () => {
    it("findAll() should query active assets with pagination, search, and category/status filters", async () => {
      jest.spyOn(prisma.asset, "findMany").mockResolvedValue([mockAsset]);
      jest.spyOn(prisma.asset, "count").mockResolvedValue(1);

      const result = await assetRepository.findAll({
        page: 1,
        limit: 10,
        search: "IT-001",
        spaceId: mockSpace.id,
        categoryId: mockCategory.id,
        status: AssetStatus.OPERATIONAL,
      });

      expect(prisma.asset.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
          where: expect.objectContaining({
            deletedAt: null,
            spaceId: mockSpace.id,
            categoryId: mockCategory.id,
            status: AssetStatus.OPERATIONAL,
            OR: [
              { name: { contains: "IT-001", mode: "insensitive" } },
              { code: { contains: "IT-001", mode: "insensitive" } },
            ],
          }),
        })
      );
      expect(result.data).toEqual([mockAsset]);
      expect(result.meta).toEqual({
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1,
        hasNext: false,
        hasPrevious: false,
      });
    });

    it("findById() should query active asset by ID", async () => {
      jest.spyOn(prisma.asset, "findFirst").mockResolvedValue(mockAsset);

      const result = await assetRepository.findById(mockAsset.id);
      expect(prisma.asset.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockAsset.id, deletedAt: null },
        })
      );
      expect(result).toEqual(mockAsset);
    });

    it("findByCode() should query active asset by unique code", async () => {
      jest.spyOn(prisma.asset, "findFirst").mockResolvedValue(mockAsset);

      const result = await assetRepository.findByCode("IT-001");
      expect(prisma.asset.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { code: "IT-001", deletedAt: null },
        })
      );
      expect(result).toEqual(mockAsset);
    });

    it("findByName() should query active asset by spaceId and name", async () => {
      jest.spyOn(prisma.asset, "findFirst").mockResolvedValue(mockAsset);

      const result = await assetRepository.findByName(mockSpace.id, "4K Laser Projection System");
      expect(prisma.asset.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { spaceId: mockSpace.id, name: "4K Laser Projection System", deletedAt: null },
        })
      );
      expect(result).toEqual(mockAsset);
    });

    it("findByQrCode() should query active asset by qrCode", async () => {
      jest.spyOn(prisma.asset, "findFirst").mockResolvedValue(mockAsset);

      const result = await assetRepository.findByQrCode("QR-AV-AUD-PROJ-01");
      expect(prisma.asset.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { qrCode: "QR-AV-AUD-PROJ-01", deletedAt: null },
        })
      );
      expect(result).toEqual(mockAsset);
    });

    it("findBySpace() should query active assets for a space", async () => {
      jest.spyOn(prisma.asset, "findMany").mockResolvedValue([mockAsset]);

      const result = await assetRepository.findBySpace(mockSpace.id);
      expect(prisma.asset.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { spaceId: mockSpace.id, deletedAt: null },
        })
      );
      expect(result).toEqual([mockAsset]);
    });

    it("create() should insert an asset record into DB", async () => {
      const createData = {
        spaceId: mockSpace.id,
        categoryId: mockCategory.id,
        name: "4K Laser Projection System",
        code: "IT-001",
        status: AssetStatus.OPERATIONAL,
      };
      jest.spyOn(prisma.asset, "create").mockResolvedValue({ id: "new-asset-id", ...createData });

      const result = await assetRepository.create(createData);
      expect(prisma.asset.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: createData })
      );
      expect(result.id).toBe("new-asset-id");
    });

    it("update() should update asset record by ID", async () => {
      const updateData = { status: AssetStatus.FAULTY };
      jest.spyOn(prisma.asset, "update").mockResolvedValue({ ...mockAsset, ...updateData });

      const result = await assetRepository.update(mockAsset.id, updateData);
      expect(prisma.asset.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockAsset.id },
          data: updateData,
        })
      );
      expect(result.status).toBe(AssetStatus.FAULTY);
    });

    it("delete() should soft-delete asset record by setting deletedAt timestamp", async () => {
      jest.spyOn(prisma.asset, "update").mockResolvedValue({ ...mockAsset, deletedAt: new Date() });

      const result = await assetRepository.delete(mockAsset.id);
      expect(prisma.asset.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockAsset.id },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        })
      );
      expect(result.deletedAt).toBeDefined();
    });
  });

  // ─── 2. Service Specs ──────────────────────────────────────────────────────
  describe("AssetService Specs", () => {
    it("createAsset() should throw 404 if Space is not found", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(null);

      await expect(
        assetService.createAsset({
          spaceId: "non-existent-space",
          categoryId: mockCategory.id,
          name: "Projection System",
          code: "IT-001",
        })
      ).rejects.toThrow(/space with id non-existent-space not found/i);
    });

    it("createAsset() should throw 404 if AssetCategory is not found", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(null);

      await expect(
        assetService.createAsset({
          spaceId: mockSpace.id,
          categoryId: "non-existent-category",
          name: "Projection System",
          code: "IT-001",
        })
      ).rejects.toThrow(/asset category with id non-existent-category not found/i);
    });

    it("createAsset() should throw 400 if AssetStatus is invalid", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(mockCategory);

      await expect(
        assetService.createAsset({
          spaceId: mockSpace.id,
          categoryId: mockCategory.id,
          name: "Projection System",
          code: "IT-001",
          status: "INVALID_STATUS",
        })
      ).rejects.toThrow(/invalid assetstatus/i);
    });

    it("createAsset() should throw 409 if asset code is already taken across campus", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(mockCategory);
      jest.spyOn(assetRepository, "findByCode").mockResolvedValue(mockAsset);

      await expect(
        assetService.createAsset({
          spaceId: mockSpace.id,
          categoryId: mockCategory.id,
          name: "Different Asset",
          code: "IT-001",
        })
      ).rejects.toThrow(/asset code 'IT-001' already exists/i);
    });

    it("createAsset() should throw 409 if asset name already exists in the same space", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(mockCategory);
      jest.spyOn(assetRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(assetRepository, "findByName").mockResolvedValue(mockAsset);

      await expect(
        assetService.createAsset({
          spaceId: mockSpace.id,
          categoryId: mockCategory.id,
          name: "4K Laser Projection System",
          code: "IT-002",
        })
      ).rejects.toThrow(/asset name '4K Laser Projection System' already exists in this space/i);
    });

    it("createAsset() should throw 409 if QR code already exists", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(mockCategory);
      jest.spyOn(assetRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(assetRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(assetRepository, "findByQrCode").mockResolvedValue(mockAsset);

      await expect(
        assetService.createAsset({
          spaceId: mockSpace.id,
          categoryId: mockCategory.id,
          name: "New System",
          code: "IT-002",
          qrCode: "QR-AV-AUD-PROJ-01",
        })
      ).rejects.toThrow(/qr code 'QR-AV-AUD-PROJ-01' already exists/i);
    });

    it("updateAsset() should throw 404 if Asset does not exist", async () => {
      jest.spyOn(assetRepository, "findById").mockResolvedValue(null);

      await expect(
        assetService.updateAsset("non-existent-asset-id", { name: "Updated" })
      ).rejects.toThrow(/not found/i);
    });

    it("deleteAsset() should soft-delete asset record", async () => {
      jest.spyOn(assetRepository, "findById").mockResolvedValue(mockAsset);
      jest.spyOn(assetRepository, "delete").mockResolvedValue({ ...mockAsset, deletedAt: new Date() });

      const result = await assetService.deleteAsset(mockAsset.id);
      expect(result).toEqual({ id: mockAsset.id, deleted: true });
    });
  });

  // ─── 3. API Integration Specs ──────────────────────────────────────────────
  describe("API Integration Specs (/api/v1/assets)", () => {
    it("GET /api/v1/assets should return paginated active assets with metadata", async () => {
      jest.spyOn(assetRepository, "findAll").mockResolvedValue({
        data: [mockAsset],
        meta: { page: 1, limit: 10, total: 1, totalPages: 1, hasNext: false, hasPrevious: false },
      });

      const res = await request(app).get(`/api/v1/assets?page=1&limit=10&search=IT-001`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Assets retrieved successfully");
      expect(res.body.data).toHaveLength(1);
      expect(res.body.meta).toEqual({
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1,
        hasNext: false,
        hasPrevious: false,
      });
    });

    it("GET /api/v1/assets/:id should return asset details when present", async () => {
      jest.spyOn(assetRepository, "findById").mockResolvedValue(mockAsset);

      const res = await request(app).get(`/api/v1/assets/${mockAsset.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe("4K Laser Projection System");
      expect(res.body.data.code).toBe("IT-001");
    });

    it("GET /api/v1/assets/:id should return 404 when asset is missing", async () => {
      jest.spyOn(assetRepository, "findById").mockResolvedValue(null);

      const res = await request(app).get("/api/v1/assets/00000000-0000-4000-8000-000000000000");

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/not found/i);
    });

    it("POST /api/v1/assets should create new asset and return 201", async () => {
      const payload = {
        spaceId: mockSpace.id,
        categoryId: mockCategory.id,
        name: "Interactive Display 75-inch",
        code: "it-003", // uppercase transformation
        status: AssetStatus.OPERATIONAL,
      };

      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(mockCategory);
      jest.spyOn(assetRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(assetRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(assetRepository, "create").mockResolvedValue({
        ...mockAsset,
        name: "Interactive Display 75-inch",
        code: "IT-003",
      });

      const res = await request(app).post("/api/v1/assets").send(payload);

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Asset created successfully");
      expect(res.body.data.code).toBe("IT-003");
    });

    it("POST /api/v1/assets should return 400 when validation fails (missing required code)", async () => {
      const invalidPayload = {
        spaceId: mockSpace.id,
        categoryId: mockCategory.id,
        name: "Asset without code",
      };

      const res = await request(app).post("/api/v1/assets").send(invalidPayload);

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/validation error/i);
    });

    it("POST /api/v1/assets should return 409 when asset code is already taken", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(prisma.assetCategory, "findFirst").mockResolvedValue(mockCategory);
      jest.spyOn(assetRepository, "findByCode").mockResolvedValue(mockAsset);

      const payload = {
        spaceId: mockSpace.id,
        categoryId: mockCategory.id,
        name: "Duplicate Code Asset",
        code: "IT-001",
      };

      const res = await request(app).post("/api/v1/assets").send(payload);

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/already exists/i);
    });

    it("PUT /api/v1/assets/:id should update asset details", async () => {
      const updatePayload = { status: AssetStatus.UNDER_MAINTENANCE };
      const updatedAsset = { ...mockAsset, status: AssetStatus.UNDER_MAINTENANCE };

      jest.spyOn(assetRepository, "findById").mockResolvedValue(mockAsset);
      jest.spyOn(assetRepository, "update").mockResolvedValue(updatedAsset);

      const res = await request(app).put(`/api/v1/assets/${mockAsset.id}`).send(updatePayload);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Asset updated successfully");
      expect(res.body.data.status).toBe(AssetStatus.UNDER_MAINTENANCE);
    });

    it("DELETE /api/v1/assets/:id should soft-delete asset record", async () => {
      jest.spyOn(assetRepository, "findById").mockResolvedValue(mockAsset);
      jest.spyOn(assetRepository, "delete").mockResolvedValue({ ...mockAsset, deletedAt: new Date() });

      const res = await request(app).delete(`/api/v1/assets/${mockAsset.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Asset deleted successfully");
      expect(res.body.data.deleted).toBe(true);
    });
  });
});
