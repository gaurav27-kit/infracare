import request from "supertest";
import app from "../src/app.js";
import spaceRepository from "../src/repositories/space/space.repository.js";
import floorRepository from "../src/repositories/floor/floor.repository.js";
import spaceService from "../src/services/space.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";
import { SpaceType } from "../src/types/enums.js";

describe("Space Module Tests", () => {
  const mockBuilding = {
    id: "00000000-0000-4000-8000-000000000000",
    name: "Academic Block A",
    code: "ACAD-BLK-A",
  };

  const mockFloor1 = {
    id: "11111111-1111-4111-8111-111111111111",
    level: 1,
    name: "Ground Floor",
    buildingId: mockBuilding.id,
    building: mockBuilding,
  };

  const mockFloor2 = {
    id: "22222222-2222-4222-8222-222222222222",
    level: 2,
    name: "First Floor",
    buildingId: mockBuilding.id,
    building: mockBuilding,
  };

  const mockSpace = {
    id: "33333333-3333-4333-8333-333333333333",
    floorId: mockFloor1.id,
    name: "Lecture Hall 101",
    code: "LH-101",
    type: SpaceType.CLASSROOM,
    capacity: 80,
    isAccessible: true,
    isActive: true,
    floor: mockFloor1,
    _count: { assets: 2 },
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Specs ───────────────────────────────────────────────────
  describe("SpaceRepository Unit Specs", () => {
    it("findAll() should query active spaces with pagination, search, and type filters", async () => {
      jest.spyOn(prisma.space, "findMany").mockResolvedValue([mockSpace]);
      jest.spyOn(prisma.space, "count").mockResolvedValue(1);

      const result = await spaceRepository.findAll({
        page: 1,
        limit: 10,
        search: "LH-101",
        type: SpaceType.CLASSROOM,
        floorId: mockFloor1.id,
      });

      expect(prisma.space.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
          where: expect.objectContaining({
            deletedAt: null,
            isActive: true,
            floorId: mockFloor1.id,
            type: SpaceType.CLASSROOM,
            OR: [
              { name: { contains: "LH-101", mode: "insensitive" } },
              { code: { contains: "LH-101", mode: "insensitive" } },
            ],
          }),
        })
      );
      expect(result.data).toEqual([mockSpace]);
      expect(result.meta).toEqual({
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1,
        hasNext: false,
        hasPrevious: false,
      });
    });

    it("findById() should query active space by ID", async () => {
      jest.spyOn(prisma.space, "findFirst").mockResolvedValue(mockSpace);

      const result = await spaceRepository.findById(mockSpace.id);
      expect(prisma.space.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockSpace.id, deletedAt: null },
        })
      );
      expect(result).toEqual(mockSpace);
    });

    it("findByCode() should query active space by code", async () => {
      jest.spyOn(prisma.space, "findFirst").mockResolvedValue(mockSpace);

      const result = await spaceRepository.findByCode("LH-101");
      expect(prisma.space.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { code: "LH-101", deletedAt: null },
        })
      );
      expect(result).toEqual(mockSpace);
    });

    it("findByFloor() should query active spaces for a floor", async () => {
      jest.spyOn(prisma.space, "findMany").mockResolvedValue([mockSpace]);

      const result = await spaceRepository.findByFloor(mockFloor1.id);
      expect(prisma.space.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { floorId: mockFloor1.id, deletedAt: null, isActive: true },
        })
      );
      expect(result).toEqual([mockSpace]);
    });

    it("findByName() should query active space by floorId and name", async () => {
      jest.spyOn(prisma.space, "findFirst").mockResolvedValue(mockSpace);

      const result = await spaceRepository.findByName(mockFloor1.id, "Lecture Hall 101");
      expect(prisma.space.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { floorId: mockFloor1.id, name: "Lecture Hall 101", deletedAt: null },
        })
      );
      expect(result).toEqual(mockSpace);
    });

    it("countAssets() should return count of active assets for a space", async () => {
      jest.spyOn(prisma.asset, "count").mockResolvedValue(2);

      const count = await spaceRepository.countAssets(mockSpace.id);
      expect(prisma.asset.count).toHaveBeenCalledWith({
        where: { spaceId: mockSpace.id, deletedAt: null },
      });
      expect(count).toBe(2);
    });

    it("create() should insert a space record into DB", async () => {
      const createData = {
        floorId: mockFloor1.id,
        name: "Central Seminar Hall A1",
        code: "SEM-A1",
        type: SpaceType.SEMINAR_HALL,
        capacity: 250,
      };
      jest.spyOn(prisma.space, "create").mockResolvedValue({ id: "new-space-id", ...createData });

      const result = await spaceRepository.create(createData);
      expect(prisma.space.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: createData })
      );
      expect(result.id).toBe("new-space-id");
    });

    it("update() should update space record by ID", async () => {
      const updateData = { capacity: 100 };
      jest.spyOn(prisma.space, "update").mockResolvedValue({ ...mockSpace, ...updateData });

      const result = await spaceRepository.update(mockSpace.id, updateData);
      expect(prisma.space.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockSpace.id },
          data: updateData,
        })
      );
      expect(result.capacity).toBe(100);
    });

    it("delete() should soft-delete space record by setting deletedAt timestamp", async () => {
      jest.spyOn(prisma.space, "update").mockResolvedValue({ ...mockSpace, deletedAt: new Date() });

      const result = await spaceRepository.delete(mockSpace.id);
      expect(prisma.space.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockSpace.id },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        })
      );
      expect(result.deletedAt).toBeDefined();
    });
  });

  // ─── 2. Service Specs ──────────────────────────────────────────────────────
  describe("SpaceService Specs", () => {
    it("createSpace() should throw 404 if Floor is not found", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(null);

      await expect(
        spaceService.createSpace({
          floorId: "non-existent-floor",
          name: "Lecture Hall 101",
          code: "LH-101",
          type: SpaceType.CLASSROOM,
        })
      ).rejects.toThrow(/floor with id non-existent-floor not found/i);
    });

    it("createSpace() should throw 400 if SpaceType is invalid", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor1);

      await expect(
        spaceService.createSpace({
          floorId: mockFloor1.id,
          name: "Invalid Room",
          code: "INV-01",
          type: "INVALID_TYPE",
        })
      ).rejects.toThrow(/invalid spacetype/i);
    });

    it("createSpace() should throw 409 if space code is already taken across campus", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor1);
      jest.spyOn(spaceRepository, "findByCode").mockResolvedValue(mockSpace);

      await expect(
        spaceService.createSpace({
          floorId: mockFloor1.id,
          name: "Another Room",
          code: "LH-101",
          type: SpaceType.CLASSROOM,
        })
      ).rejects.toThrow(/space code 'LH-101' already exists/i);
    });

    it("createSpace() should throw 409 if space name already exists on the same floor", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor1);
      jest.spyOn(spaceRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(spaceRepository, "findByName").mockResolvedValue(mockSpace);

      await expect(
        spaceService.createSpace({
          floorId: mockFloor1.id,
          name: "Lecture Hall 101",
          code: "LH-102",
          type: SpaceType.CLASSROOM,
        })
      ).rejects.toThrow(/space name 'Lecture Hall 101' already exists on this floor/i);
    });

    it("createSpace() should allow duplicate space name on a DIFFERENT floor", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor2);
      jest.spyOn(spaceRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(spaceRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(spaceRepository, "create").mockResolvedValue({
        ...mockSpace,
        id: "space-on-floor-2",
        floorId: mockFloor2.id,
        code: "LH-201",
      });

      const result = await spaceService.createSpace({
        floorId: mockFloor2.id,
        name: "Lecture Hall 101",
        code: "LH-201",
        type: SpaceType.CLASSROOM,
      });

      expect(result.floorId).toBe(mockFloor2.id);
    });

    it("updateSpace() should throw 404 if Space does not exist", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(null);

      await expect(
        spaceService.updateSpace("non-existent-space-id", { name: "Updated" })
      ).rejects.toThrow(/not found/i);
    });

    it("deleteSpace() should throw 409 Conflict if Space contains active assets", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(spaceRepository, "countAssets").mockResolvedValue(3);

      await expect(
        spaceService.deleteSpace(mockSpace.id)
      ).rejects.toThrow(/cannot delete space because it contains assets/i);
    });

    it("deleteSpace() should soft-delete space when it contains 0 assets", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(spaceRepository, "countAssets").mockResolvedValue(0);
      jest.spyOn(spaceRepository, "delete").mockResolvedValue({ ...mockSpace, deletedAt: new Date() });

      const result = await spaceService.deleteSpace(mockSpace.id);
      expect(result).toEqual({ id: mockSpace.id, deleted: true });
    });
  });

  // ─── 3. API Integration Specs ──────────────────────────────────────────────
  describe("API Integration Specs (/api/v1/spaces)", () => {
    it("GET /api/v1/spaces should return paginated active spaces with metadata", async () => {
      jest.spyOn(spaceRepository, "findAll").mockResolvedValue({
        data: [mockSpace],
        meta: { page: 1, limit: 10, total: 1, totalPages: 1, hasNext: false, hasPrevious: false },
      });

      const res = await request(app).get(`/api/v1/spaces?page=1&limit=10&search=LH-101`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Spaces retrieved successfully");
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

    it("GET /api/v1/spaces/:id should return space details when present", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);

      const res = await request(app).get(`/api/v1/spaces/${mockSpace.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe("Lecture Hall 101");
      expect(res.body.data.code).toBe("LH-101");
    });

    it("GET /api/v1/spaces/:id should return 404 when space is missing", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(null);

      const res = await request(app).get("/api/v1/spaces/00000000-0000-4000-8000-000000000000");

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/not found/i);
    });

    it("POST /api/v1/spaces should create new space with code and return 201", async () => {
      const payload = {
        floorId: mockFloor1.id,
        name: "Central Seminar Hall A1",
        code: "sem-a1", // uppercase transformation
        type: SpaceType.SEMINAR_HALL,
        capacity: 250,
      };

      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor1);
      jest.spyOn(spaceRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(spaceRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(spaceRepository, "create").mockResolvedValue({
        ...mockSpace,
        name: "Central Seminar Hall A1",
        code: "SEM-A1",
        type: SpaceType.SEMINAR_HALL,
        capacity: 250,
      });

      const res = await request(app).post("/api/v1/spaces").send(payload);

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Space created successfully");
      expect(res.body.data.code).toBe("SEM-A1");
    });

    it("POST /api/v1/spaces should return 400 when validation fails (missing code)", async () => {
      const invalidPayload = {
        floorId: mockFloor1.id,
        name: "Lab 1",
        type: SpaceType.LABORATORY,
      };

      const res = await request(app).post("/api/v1/spaces").send(invalidPayload);

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/validation error/i);
    });

    it("POST /api/v1/spaces should return 409 when space code is already taken", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor1);
      jest.spyOn(spaceRepository, "findByCode").mockResolvedValue(mockSpace);

      const payload = {
        floorId: mockFloor1.id,
        name: "Another Room",
        code: "LH-101",
        type: SpaceType.CLASSROOM,
      };

      const res = await request(app).post("/api/v1/spaces").send(payload);

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/already exists/i);
    });

    it("PUT /api/v1/spaces/:id should update space details", async () => {
      const updatePayload = { capacity: 120 };
      const updatedSpace = { ...mockSpace, capacity: 120 };

      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(spaceRepository, "update").mockResolvedValue(updatedSpace);

      const res = await request(app).put(`/api/v1/spaces/${mockSpace.id}`).send(updatePayload);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Space updated successfully");
      expect(res.body.data.capacity).toBe(120);
    });

    it("DELETE /api/v1/spaces/:id should return 409 when space contains assets", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(spaceRepository, "countAssets").mockResolvedValue(2);

      const res = await request(app).delete(`/api/v1/spaces/${mockSpace.id}`);

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe("Cannot delete space because it contains assets.");
    });

    it("DELETE /api/v1/spaces/:id should soft-delete space when it contains 0 assets", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(spaceRepository, "countAssets").mockResolvedValue(0);
      jest.spyOn(spaceRepository, "delete").mockResolvedValue({ ...mockSpace, deletedAt: new Date() });

      const res = await request(app).delete(`/api/v1/spaces/${mockSpace.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Space deleted successfully");
      expect(res.body.data.deleted).toBe(true);
    });
  });
});
