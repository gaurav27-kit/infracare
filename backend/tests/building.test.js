import request from "supertest";
import app from "../src/app.js";
import buildingRepository from "../src/repositories/building/building.repository.js";
import campusRepository from "../src/repositories/campus/campus.repository.js";
import buildingService from "../src/services/building.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";

describe("Building Module Tests", () => {
  const mockCampus = {
    id: "11111111-1111-1111-1111-111111111111",
    name: "ABC Engineering College",
    code: "ABC",
  };

  const mockBuilding = {
    id: "22222222-2222-2222-2222-222222222222",
    campusId: mockCampus.id,
    name: "Academic Block A",
    code: "ACAD-BLK-A",
    campus: mockCampus,
    _count: { floors: 3 },
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Tests ───────────────────────────────────────────────────
  describe("BuildingRepository Unit Specs", () => {
    it("findAll() should query active buildings from Prisma", async () => {
      const mockList = [mockBuilding];
      jest.spyOn(prisma.building, "findMany").mockResolvedValue(mockList);

      const result = await buildingRepository.findAll();
      expect(prisma.building.findMany).toHaveBeenCalled();
      expect(result).toEqual(mockList);
    });

    it("findById() should query active building by ID", async () => {
      jest.spyOn(prisma.building, "findFirst").mockResolvedValue(mockBuilding);

      const result = await buildingRepository.findById(mockBuilding.id);
      expect(prisma.building.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockBuilding.id, deletedAt: null },
        })
      );
      expect(result).toEqual(mockBuilding);
    });

    it("findByCode() should query active building by code", async () => {
      jest.spyOn(prisma.building, "findFirst").mockResolvedValue(mockBuilding);

      const result = await buildingRepository.findByCode("ACAD-BLK-A");
      expect(prisma.building.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { code: "ACAD-BLK-A", deletedAt: null },
        })
      );
      expect(result).toEqual(mockBuilding);
    });

    it("findByName() should query active building by name", async () => {
      jest.spyOn(prisma.building, "findFirst").mockResolvedValue(mockBuilding);

      const result = await buildingRepository.findByName("Academic Block A");
      expect(prisma.building.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { name: "Academic Block A", deletedAt: null },
        })
      );
      expect(result).toEqual(mockBuilding);
    });

    it("create() should insert a building record into DB", async () => {
      const createData = { name: "Science Block", code: "SCI-BLK", campusId: mockCampus.id };
      jest.spyOn(prisma.building, "create").mockResolvedValue({ id: "new-id", ...createData });

      const result = await buildingRepository.create(createData);
      expect(prisma.building.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: createData })
      );
      expect(result.id).toBe("new-id");
    });

    it("update() should update building record by ID", async () => {
      const updateData = { name: "Academic Block Alpha" };
      jest.spyOn(prisma.building, "update").mockResolvedValue({ ...mockBuilding, ...updateData });

      const result = await buildingRepository.update(mockBuilding.id, updateData);
      expect(prisma.building.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockBuilding.id },
          data: updateData,
        })
      );
      expect(result.name).toBe("Academic Block Alpha");
    });

    it("delete() should soft-delete building record by setting deletedAt timestamp", async () => {
      jest.spyOn(prisma.building, "update").mockResolvedValue({ ...mockBuilding, deletedAt: new Date() });

      const result = await buildingRepository.delete(mockBuilding.id);
      expect(prisma.building.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockBuilding.id },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        })
      );
      expect(result.deletedAt).toBeDefined();
    });
  });

  // ─── 2. Service Business Logic Tests ───────────────────────────────────────
  describe("BuildingService Specs", () => {
    it("createBuilding() should throw 404 if single campus is missing", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(null);

      await expect(
        buildingService.createBuilding({ name: "New Block", code: "NEW-BLK" })
      ).rejects.toThrow(/campus configuration not found/i);
    });

    it("createBuilding() should throw 409 if building code is already taken", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(mockCampus);
      jest.spyOn(buildingRepository, "findByCode").mockResolvedValue(mockBuilding);

      await expect(
        buildingService.createBuilding({ name: "New Block", code: "ACAD-BLK-A" })
      ).rejects.toThrow(/building code 'ACAD-BLK-A' already exists/i);
    });

    it("createBuilding() should throw 409 if building name is already taken", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(mockCampus);
      jest.spyOn(buildingRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(buildingRepository, "findByName").mockResolvedValue(mockBuilding);

      await expect(
        buildingService.createBuilding({ name: "Academic Block A", code: "NEW-BLK" })
      ).rejects.toThrow(/building name 'Academic Block A' already exists/i);
    });

    it("createBuilding() should create building under single campus", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(mockCampus);
      jest.spyOn(buildingRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(buildingRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(buildingRepository, "create").mockResolvedValue(mockBuilding);

      const result = await buildingService.createBuilding({ name: "Academic Block A", code: "ACAD-BLK-A" });
      expect(result).toEqual(mockBuilding);
    });

    it("updateBuilding() should throw 404 if building does not exist", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(null);

      await expect(
        buildingService.updateBuilding("non-existent-id", { name: "Updated Name" })
      ).rejects.toThrow(/not found/i);
    });

    it("updateBuilding() should throw 409 if new code collides with another building", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding);
      jest.spyOn(buildingRepository, "findByCode").mockResolvedValue({
        ...mockBuilding,
        id: "33333333-3333-3333-3333-333333333333",
        code: "TAKEN-CODE",
      });

      await expect(
        buildingService.updateBuilding(mockBuilding.id, { code: "TAKEN-CODE" })
      ).rejects.toThrow(/building code 'TAKEN-CODE' already exists/i);
    });
  });

  // ─── 3. API Integration Tests ──────────────────────────────────────────────
  describe("API Integration Specs (/api/v1/buildings)", () => {
    it("GET /api/v1/buildings should return list of active buildings", async () => {
      jest.spyOn(buildingRepository, "findAll").mockResolvedValue([mockBuilding]);

      const res = await request(app).get("/api/v1/buildings");

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Buildings retrieved successfully");
      expect(res.body.data).toHaveLength(1);
      expect(res.body.data[0].code).toBe("ACAD-BLK-A");
    });

    it("GET /api/v1/buildings/:id should return building details when present", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding);

      const res = await request(app).get(`/api/v1/buildings/${mockBuilding.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe("Academic Block A");
    });

    it("GET /api/v1/buildings/:id should return 404 when building is not found", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(null);

      const res = await request(app).get("/api/v1/buildings/00000000-0000-0000-0000-000000000000");

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/not found/i);
    });

    it("POST /api/v1/buildings should create new building and return 201", async () => {
      const payload = { name: "Science Block", code: "sci-blk" }; // code transforms to upper
      const createdBuilding = { ...mockBuilding, name: "Science Block", code: "SCI-BLK" };

      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(mockCampus);
      jest.spyOn(buildingRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(buildingRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(buildingRepository, "create").mockResolvedValue(createdBuilding);

      const res = await request(app).post("/api/v1/buildings").send(payload);

      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Building created successfully");
      expect(res.body.data.code).toBe("SCI-BLK");
    });

    it("POST /api/v1/buildings should return 400 when validation fails (short name)", async () => {
      const invalidPayload = { name: "A", code: "BLK" };

      const res = await request(app).post("/api/v1/buildings").send(invalidPayload);

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/validation error/i);
    });

    it("POST /api/v1/buildings should return 409 when code already exists", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(mockCampus);
      jest.spyOn(buildingRepository, "findByCode").mockResolvedValue(mockBuilding);

      const payload = { name: "Another Block", code: "ACAD-BLK-A" };
      const res = await request(app).post("/api/v1/buildings").send(payload);

      expect(res.statusCode).toBe(409);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/already exists/i);
    });

    it("PUT /api/v1/buildings/:id should update building details", async () => {
      const updatePayload = { name: "Academic Block Main" };
      const updatedBuilding = { ...mockBuilding, name: "Academic Block Main" };

      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding);
      jest.spyOn(buildingRepository, "findByName").mockResolvedValue(null);
      jest.spyOn(buildingRepository, "update").mockResolvedValue(updatedBuilding);

      const res = await request(app).put(`/api/v1/buildings/${mockBuilding.id}`).send(updatePayload);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Building updated successfully");
      expect(res.body.data.name).toBe("Academic Block Main");
    });

    it("DELETE /api/v1/buildings/:id should soft-delete building", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(mockBuilding);
      jest.spyOn(buildingRepository, "delete").mockResolvedValue({ ...mockBuilding, deletedAt: new Date() });

      const res = await request(app).delete(`/api/v1/buildings/${mockBuilding.id}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Building deleted successfully");
      expect(res.body.data.deleted).toBe(true);
    });

    it("DELETE /api/v1/buildings/:id should return 404 if building does not exist", async () => {
      jest.spyOn(buildingRepository, "findById").mockResolvedValue(null);

      const res = await request(app).delete("/api/v1/buildings/00000000-0000-0000-0000-000000000000");

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/not found/i);
    });
  });
});
