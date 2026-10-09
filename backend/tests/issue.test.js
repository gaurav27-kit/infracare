import request from "supertest";
import app from "../src/app.js";
import issueRepository from "../src/repositories/issue/issue.repository.js";
import spaceRepository from "../src/repositories/space/space.repository.js";
import assetRepository from "../src/repositories/asset/asset.repository.js";
import issueService from "../src/services/issue.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";
import { IssuePriority, IssueStatus } from "../src/types/enums.js";

describe("Issue Module Tests", () => {
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

  const mockAsset = {
    id: "33333333-3333-4333-8333-333333333333",
    spaceId: mockSpace.id,
    name: "4K Laser Projection System",
    code: "IT-001",
    status: "OPERATIONAL",
  };

  const mockIssue = {
    id: "44444444-4444-4444-8444-444444444444",
    issueNumber: "ISS-0001",
    spaceId: mockSpace.id,
    assetId: mockAsset.id,
    title: "Water Leakage Near Projector",
    description: "Ceiling water leakage noticed above the projector in Seminar Hall A1.",
    priority: IssuePriority.HIGH,
    status: IssueStatus.OPEN,
    reporterExternalUserId: "ext-user-1",
    space: mockSpace,
    asset: mockAsset,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Specs ───────────────────────────────────────────────────
  describe("IssueRepository Unit Specs", () => {
    it("findAll() should query active issues with search, filters, pagination and newest-first order", async () => {
      jest.spyOn(prisma.issue, "findMany").mockResolvedValue([mockIssue]);
      jest.spyOn(prisma.issue, "count").mockResolvedValue(1);

      const result = await issueRepository.findAll({
        page: 1,
        limit: 10,
        search: "ISS-0001",
        spaceId: mockSpace.id,
        assetId: mockAsset.id,
        priority: IssuePriority.HIGH,
        status: IssueStatus.OPEN,
      });

      expect(prisma.issue.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
          where: expect.objectContaining({
            deletedAt: null,
            spaceId: mockSpace.id,
            assetId: mockAsset.id,
            priority: IssuePriority.HIGH,
            status: IssueStatus.OPEN,
            OR: [
              { issueNumber: { contains: "ISS-0001", mode: "insensitive" } },
              { title: { contains: "ISS-0001", mode: "insensitive" } },
            ],
          }),
          orderBy: [{ createdAt: "desc" }],
        })
      );
      expect(result.data).toEqual([mockIssue]);
      expect(result.meta.total).toBe(1);
    });

    it("findById() should find active issue by ID", async () => {
      jest.spyOn(prisma.issue, "findFirst").mockResolvedValue(mockIssue);

      const result = await issueRepository.findById(mockIssue.id);

      expect(prisma.issue.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockIssue.id, deletedAt: null },
        })
      );
      expect(result).toEqual(mockIssue);
    });

    it("findByIssueNumber() should find active issue by issue number", async () => {
      jest.spyOn(prisma.issue, "findFirst").mockResolvedValue(mockIssue);

      const result = await issueRepository.findByIssueNumber("ISS-0001");

      expect(prisma.issue.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { issueNumber: "ISS-0001", deletedAt: null },
        })
      );
      expect(result).toEqual(mockIssue);
    });

    it("findLatestIssue() should query the latest created issue", async () => {
      jest.spyOn(prisma.issue, "findFirst").mockResolvedValue({ issueNumber: "ISS-0005" });

      const result = await issueRepository.findLatestIssue();

      expect(prisma.issue.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { deletedAt: null },
          orderBy: { createdAt: "desc" },
        })
      );
      expect(result).toEqual({ issueNumber: "ISS-0005" });
    });

    it("create() should persist a new issue record", async () => {
      jest.spyOn(prisma.issue, "create").mockResolvedValue(mockIssue);

      const result = await issueRepository.create({
        issueNumber: "ISS-0001",
        spaceId: mockSpace.id,
        title: mockIssue.title,
        description: mockIssue.description,
      });

      expect(prisma.issue.create).toHaveBeenCalled();
      expect(result).toEqual(mockIssue);
    });

    it("update() should modify an existing issue record", async () => {
      const updatedMock = { ...mockIssue, status: IssueStatus.IN_PROGRESS };
      jest.spyOn(prisma.issue, "update").mockResolvedValue(updatedMock);

      const result = await issueRepository.update(mockIssue.id, { status: IssueStatus.IN_PROGRESS });

      expect(prisma.issue.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockIssue.id },
          data: { status: IssueStatus.IN_PROGRESS },
        })
      );
      expect(result.status).toBe(IssueStatus.IN_PROGRESS);
    });

    it("delete() should soft-delete issue record by setting deletedAt timestamp", async () => {
      const deletedMock = { ...mockIssue, deletedAt: new Date() };
      jest.spyOn(prisma.issue, "update").mockResolvedValue(deletedMock);

      const result = await issueRepository.delete(mockIssue.id);

      expect(prisma.issue.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockIssue.id },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        })
      );
      expect(result.deletedAt).toBeDefined();
    });
  });

  // ─── 2. Service Unit Specs ─────────────────────────────────────────────────
  describe("IssueService Unit Specs", () => {
    it("generateIssueNumber() should auto-generate sequential numbers starting at ISS-0001", async () => {
      jest.spyOn(issueRepository, "findLatestIssue").mockResolvedValue(null);
      jest.spyOn(issueRepository, "findByIssueNumber").mockResolvedValue(null);

      const code = await issueService.generateIssueNumber();
      expect(code).toBe("ISS-0001");
    });

    it("generateIssueNumber() should increment from highest existing issue number", async () => {
      jest.spyOn(issueRepository, "findLatestIssue").mockResolvedValue({ issueNumber: "ISS-0003" });
      jest.spyOn(issueRepository, "findByIssueNumber").mockResolvedValue(null);

      const code = await issueService.generateIssueNumber();
      expect(code).toBe("ISS-0004");
    });

    it("createIssue() should set default status OPEN and priority MEDIUM if omitted", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(issueRepository, "findLatestIssue").mockResolvedValue(null);
      jest.spyOn(issueRepository, "findByIssueNumber").mockResolvedValue(null);
      jest.spyOn(issueRepository, "create").mockImplementation(async (data) => ({
        ...mockIssue,
        ...data,
      }));

      const payload = {
        spaceId: mockSpace.id,
        title: "Broken Air Conditioner",
        description: "AC is making loud noise and not cooling.",
      };

      const result = await issueService.createIssue(payload);

      expect(result.priority).toBe(IssuePriority.MEDIUM);
      expect(result.status).toBe(IssueStatus.OPEN);
      expect(result.issueNumber).toBe("ISS-0001");
    });

    it("createIssue() should throw 404 when spaceId is not found", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(null);

      await expect(
        issueService.createIssue({
          spaceId: "00000000-0000-0000-0000-000000000000",
          title: "Broken Air Conditioner",
          description: "AC is making loud noise and not cooling.",
        })
      ).rejects.toThrow("Space with ID 00000000-0000-0000-0000-000000000000 not found");
    });

    it("createIssue() should throw 400 when supplied assetId does not exist", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(assetRepository, "findById").mockResolvedValue(null);

      await expect(
        issueService.createIssue({
          spaceId: mockSpace.id,
          assetId: "99999999-9999-9999-9999-999999999999",
          title: "Broken Air Conditioner",
          description: "AC is making loud noise and not cooling.",
        })
      ).rejects.toThrow("Asset with ID 99999999-9999-9999-9999-999999999999 not found");
    });

    it("createIssue() should throw 400 when supplied asset does not belong to selected space", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(assetRepository, "findById").mockResolvedValue({
        ...mockAsset,
        spaceId: "other-space-id",
      });

      await expect(
        issueService.createIssue({
          spaceId: mockSpace.id,
          assetId: mockAsset.id,
          title: "Broken Air Conditioner",
          description: "AC is making loud noise and not cooling.",
        })
      ).rejects.toThrow(`Asset with ID ${mockAsset.id} does not belong to Space ${mockSpace.id}`);
    });
  });

  // ─── 3. Route & Controller Integration Specs ──────────────────────────────
  describe("Issue API Routes (/api/v1/issues)", () => {
    it("GET /api/v1/issues should return 200 with paginated active issues and rich response", async () => {
      jest.spyOn(issueRepository, "findAll").mockResolvedValue({
        data: [mockIssue],
        meta: { page: 1, limit: 10, total: 1, totalPages: 1, hasNext: false, hasPrevious: false },
      });

      const response = await request(app).get("/api/v1/issues").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual([JSON.parse(JSON.stringify(mockIssue))]);
      expect(response.body.meta.total).toBe(1);
    });

    it("GET /api/v1/issues/:id should return issue details when found", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);

      const response = await request(app).get(`/api/v1/issues/${mockIssue.id}`).expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(mockIssue.id);
    });

    it("GET /api/v1/issues/:id should return 404 when issue does not exist", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(null);

      const response = await request(app)
        .get("/api/v1/issues/00000000-0000-0000-0000-000000000000")
        .expect(404);

      expect(response.body.success).toBe(false);
    });

    it("POST /api/v1/issues should create a new issue and return 201", async () => {
      jest.spyOn(spaceRepository, "findById").mockResolvedValue(mockSpace);
      jest.spyOn(assetRepository, "findById").mockResolvedValue(mockAsset);
      jest.spyOn(issueRepository, "findLatestIssue").mockResolvedValue(null);
      jest.spyOn(issueRepository, "findByIssueNumber").mockResolvedValue(null);
      jest.spyOn(issueRepository, "create").mockResolvedValue(mockIssue);

      const response = await request(app)
        .post("/api/v1/issues")
        .send({
          spaceId: mockSpace.id,
          assetId: mockAsset.id,
          title: "Water Leakage Near Projector",
          description: "Ceiling water leakage noticed above the projector in Seminar Hall A1.",
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.issueNumber).toBe("ISS-0001");
    });

    it("POST /api/v1/issues should return 400 when validation fails (short title)", async () => {
      const response = await request(app)
        .post("/api/v1/issues")
        .send({
          spaceId: mockSpace.id,
          title: "Ab",
          description: "Valid description string here.",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("PUT /api/v1/issues/:id should update issue details", async () => {
      const updatedIssue = { ...mockIssue, status: IssueStatus.IN_PROGRESS };
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(assetRepository, "findById").mockResolvedValue(mockAsset);
      jest.spyOn(issueRepository, "update").mockResolvedValue(updatedIssue);

      const response = await request(app)
        .put(`/api/v1/issues/${mockIssue.id}`)
        .send({ status: IssueStatus.IN_PROGRESS })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe(IssueStatus.IN_PROGRESS);
    });

    it("DELETE /api/v1/issues/:id should soft delete issue", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(issueRepository, "delete").mockResolvedValue(mockIssue);

      const response = await request(app).delete(`/api/v1/issues/${mockIssue.id}`).expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.deleted).toBe(true);
    });
  });
});
