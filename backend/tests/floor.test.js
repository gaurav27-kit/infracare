import request from "supertest";
import app from "../src/app.js";
import floorRepository from "../src/repositories/floor/floor.repository.js";
import buildingRepository from "../src/repositories/building/building.repository.js";
import floorService from "../src/services/floor.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";

describe("Floor Module Tests", () => {
  const mockBuilding1 = {
    id: "11111111-1111-4111-8111-111111111111",
    name: "Academic Block A",
    code: "ACAD-BLK-A",
  };

  const mockBuilding2 = {
    id: "22222222-2222-4222-8222-222222222222",
    name: "Administration Block",
    code: "ADMIN-BLK",
  };

  const mockFloor = {
    id: "33333333-3333-4333-8333-333333333333",
    buildingId: mockBuilding1.id,
    level: 1,
    name: "Ground Floor",
    building: mockBuilding1,
    _count: { spaces: 2 },
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };


  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Tests ───────────────────────────────────────────────────
  describe("FloorRepository Unit Specs", () => {
    it("findAll() should query active floors with pagination and count from Prisma", async () => {
      jest.spyOn(prisma.floor, "findMany").mockResolvedValue([mockFloor]);
      jest.spyOn(prisma.floor, "count").mockResolvedValue(1);

      const result = await floorRepository.findAll({ page: 1, limit: 10, search: "Ground" });

      expect(prisma.floor.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
          where: expect.objectContaining({
            deletedAt: null,
            name: { contains: "Ground", mode: "insensitive" },
          }),
        })
      );
      expect(result.data).toEqual([mockFloor]);
      expect(result.meta).toEqual({
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1,
        hasNext: false,
        hasPrevious: false,
      });
    });

    it("findById() should query active floor by ID", async () => {
      jest.spyOn(prisma.floor, "findFirst").mockResolvedValue(mockFloor);

      const result = await floorRepository.findById(mockFloor.id);
      expect(prisma.floor.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockFloor.id, deletedAt: null },
        })
      );
      expect(result).toEqual(mockFloor);
    });

    it("findByBuilding() should query active floors for a building", async () => {
      jest.spyOn(prisma.floor, "findMany").mockResolvedValue([mockFloor]);

      const result = await floorRepository.findByBuilding(mockBuilding1.id);
      expect(prisma.floor.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { buildingId: mockBuilding1.id, deletedAt: null },
        })
      );
      expect(result).toEqual([mockFloor]);
    });

    it("findByLevel() should query active floor by buildingId and level", async () => {
      jest.spyOn(prisma.floor, "findFirst").mockResolvedValue(mockFloor);

      const result = await floorRepository.findByLevel(mockBuilding1.id, 1);
      expect(prisma.floor.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { buildingId: mockBuilding1.id, level: 1, deletedAt: null },
        })
      );
      expect(result).toEqual(mockFloor);
    });

    it("findByName() should query active floor by buildingId and name", async () => {
      jest.spyOn(prisma.floor, "findFirst").mockResolvedValue(mockFloor);

      const result = await floorRepository.findByName(mockBuilding1.id, "Ground Floor");
      expect(prisma.floor.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { buildingId: mockBuilding1.id, name: "Ground Floor", deletedAt: null },
        })
      );
      expect(result).toEqual(mockFloor);
    });

    it("countSpaces() should return count of active spaces for a floor", async () => {
      jest.spyOn(prisma.space, "count").mockResolvedValue(2);

      const count = await floorRepository.countSpaces(mockFloor.id);
      expect(prisma.space.count).toHaveBeenCalledWith({
        where: { floorId: mockFloor.id, deletedAt: null },
      });
      expect(count).toBe(2);
    });

    it("create() should insert a floor record into DB", async () => {
      const createData = { buildingId: mockBuilding1.id, level: 2, name: "First Floor" };
      jest.spyOn(prisma.floor, "create").mockResolvedValue({ id: "new-floor-id", ...createData });

      const result = await floorRepository.create(createData);
      expect(prisma.floor.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: createData })
      );
      expect(result.id).toBe("new-floor-id");
    });

    it("update() should update floor record by ID", async () => {
      const updateData = { name: "Ground Level" };
      jest.spyOn(prisma.floor, "update").mockResolvedValue({ ...mockFloor, ...updateData });

      const result = await floorRepository.update(mockFloor.id, updateData);
      expect(prisma.floor.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockFloor.id },
          data: updateData,
        })
      );
      expect(result.name).toBe("Ground Level");
    });

    it("delete() should soft-delete floor record by setting deletedAt timestamp", async () => {
      jest.spyOn(prisma.floor, "update").mockResolvedValue({ ...mockFloor, deletedAt: new Date() });

      const result = await floorRepository.delete(mockFloor.id);
      expect(prisma.floor.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockFloor.id },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        })
      );
      expect(result.deletedAt).toBeDefined();
    });
  });

  // ─── 2. Service Business Logic Tests ───────────────────────────────────────
  describe("FloorService Specs", () => {
    it("createFloor() should throw 404 if Building is not found", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(null);

      await expect(
        floorService.createFloor({ buildingId: "non-existent-bldg", name: "Ground Floor", level: 1 })
      ).rejects.toThrow(/building with id non-existent-bldg not found/i);
    });

    it("createFloor() should throw 409 if floor level already exists in the same building", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding1);
      jest.spyOn(floorRepository, "findByLevel").mockResolvedValue(mockFloor);

      await expect(
        floorService.createFloor({ buildingId: mockBuilding1.id, name: "New Level 1", level: 1 })
      ).rejects.toThrow(/floor level 1 already exists in this building/i);
    });

    it("createFloor() should throw 409 if floor name already exists in the same building", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding1);
      jest.spyOn(floorRepository, "findByLevel").mockResolvedValue(null);
      jest.spyOn(floorRepository, "findByName").mockResolvedValue(mockFloor);

      await expect(
        floorService.createFloor({ buildingId: mockBuilding1.id, name: "Ground Floor", level: 2 })
      ).rejects.toThrow(/floor name 'Ground Floor' already exists in this building/i);
    });

    it("createFloor() should allow identical floor level and name in a DIFFERENT building", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding2);
      jest.spyOn(floorRepository, "findByLevel").mockResolvedValue(null);
      jest.spyOn(floorRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(floorRepository, "create").mockResolvedValue({
        ...mockFloor,
        id: "floor-in-bldg-2",
        buildingId: mockBuilding2.id,
      });

      const result = await floorService.createFloor({
        buildingId: mockBuilding2.id,
        name: "Ground Floor",
        level: 1,
      });

      expect(result.buildingId).toBe(mockBuilding2.id);
    });

    it("updateFloor() should throw 404 if Floor does not exist", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(null);

      await expect(
        floorService.updateFloor("non-existent-floor-id", { name: "Updated" })
      ).rejects.toThrow(/not found/i);
    });

    it("updateFloor() should throw 409 if updated level collides with another floor in the same building", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);
      jest.spyOn(floorRepository, "findByLevel").mockResolvedValue({
        ...mockFloor,
        id: "other-floor-id",
        level: 2,
      });

      await expect(
        floorService.updateFloor(mockFloor.id, { level: 2 })
      ).rejects.toThrow(/floor level 2 already exists in this building/i);
    });

    it("deleteFloor() should throw 409 Conflict if Floor contains active spaces", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);
      jest.spyOn(floorRepository, "countSpaces").mockResolvedValue(3);

      await expect(
        floorService.deleteFloor(mockFloor.id)
      ).rejects.toThrow(/cannot delete floor because it contains spaces/i);
    });

    it("deleteFloor() should soft-delete successfully if Floor contains 0 spaces", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);
      jest.spyOn(floorRepository, "countSpaces").mockResolvedValue(0);
      jest.spyOn(floorRepository, "delete").mockResolvedValue({ ...mockFloor, deletedAt: new Date() });

      const result = await floorService.deleteFloor(mockFloor.id);
      expect(result).toEqual({ id: mockFloor.id, deleted: true });
    });
  });

  // ─── 3. API Integration Tests ──────────────────────────────────────────────
  describe("API Integration Specs (/api/v1/floors)", () => {
    it("GET /api/v1/floors should return paginated list of active floors", async () => {
      jest.spyOn(floorRepository, "findAll").mockResolvedValue({
        data: [mockFloor],
        meta: { total: 1, page: 1, limit: 10, totalPages: 1 },
      });

      const res = await request(app).get("/api/v1/floors?page=1&limit=10&search=Ground");

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Floors retrieved successfully");
      expect(res.body.data).toHaveLength(1);
      expect(res.body.meta.total).toBe(1);
    });

    it("GET /api/v1/floors/:id should return floor details when present", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);

      const res = await request(app).get(`/api/v1/floors/${mockFloor.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe("Ground Floor");
    });

    it("GET /api/v1/floors/:id should return 404 when floor is missing", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(null);

      const res = await request(app).get("/api/v1/floors/00000000-0000-0000-0000-000000000000");

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/not found/i);
    });

    it("POST /api/v1/floors should create new floor and return 201", async () => {
      const payload = {
        buildingId: mockBuilding1.id,
        name: "First Floor",
        level: 2,
      };

      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding1);
      jest.spyOn(floorRepository, "findByLevel").mockResolvedValue(null);
      jest.spyOn(floorRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(floorRepository, "create").mockResolvedValue({
        ...mockFloor,
        name: "First Floor",
        level: 2,
      });

      const res = await request(app).post("/api/v1/floors").send(payload);

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Floor created successfully");
      expect(res.body.data.level).toBe(2);
    });

    it("POST /api/v1/floors should return 400 on validation error (invalid buildingId UUID)", async () => {
      const invalidPayload = {
        buildingId: "not-a-uuid",
        name: "Ground Floor",
        level: 1,
      };

      const res = await request(app).post("/api/v1/floors").send(invalidPayload);

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/validation error/i);
    });

    it("POST /api/v1/floors should return 409 when floor level already exists in building", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding1);
      jest.spyOn(floorRepository, "findByLevel").mockResolvedValue(mockFloor);

      const payload = {
        buildingId: mockBuilding1.id,
        name: "Duplicate Level Floor",
        level: 1,
      };

      const res = await request(app).post("/api/v1/floors").send(payload);

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/already exists/i);
    });

    it("PUT /api/v1/floors/:id should update floor details", async () => {
      const updatePayload = { name: "Main Ground Floor" };
      const updatedFloor = { ...mockFloor, name: "Main Ground Floor" };

      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);
      jest.spyOn(floorRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(floorRepository, "update").mockResolvedValue(updatedFloor);

      const res = await request(app).put(`/api/v1/floors/${mockFloor.id}`).send(updatePayload);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Floor updated successfully");
      expect(res.body.data.name).toBe("Main Ground Floor");
    });

    it("DELETE /api/v1/floors/:id should return 409 when floor contains spaces", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);
      jest.spyOn(floorRepository, "countSpaces").mockResolvedValue(2);

      const res = await request(app).delete(`/api/v1/floors/${mockFloor.id}`);

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe("Cannot delete floor because it contains spaces.");
    });

    it("DELETE /api/v1/floors/:id should soft-delete floor when it contains 0 spaces", async () => {
      jest.spyOn(floorRepository, "findById").mockResolvedValue(mockFloor);
      jest.spyOn(floorRepository, "countSpaces").mockResolvedValue(0);
      jest.spyOn(floorRepository, "delete").mockResolvedValue({ ...mockFloor, deletedAt: new Date() });

      const res = await request(app).delete(`/api/v1/floors/${mockFloor.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Floor deleted successfully");
      expect(res.body.data.deleted).toBe(true);
    });
  });
});
