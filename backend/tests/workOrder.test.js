import request from "supertest";
import app from "../src/app.js";
import workOrderRepository from "../src/repositories/workOrder/workOrder.repository.js";
import issueRepository from "../src/repositories/issue/issue.repository.js";
import workOrderService from "../src/services/workOrder.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";
import { WorkOrderPriority, WorkOrderStatus } from "../src/types/enums.js";

describe("WorkOrder Module Tests", () => {
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

  const mockIssue = {
    id: "33333333-3333-4333-8333-333333333333",
    issueNumber: "ISS-0001",
    title: "Water Leakage Near Projector",
    description: "Ceiling water leakage noticed above the projector in Seminar Hall A1.",
    priority: "HIGH",
    status: "OPEN",
    space: mockSpace,
  };

  const mockDepartment = {
    id: "44444444-4444-4444-8444-444444444444",
    name: "Civil & Plumbing",
    code: "DEPT-CIVIL",
    email: "civil@campus.edu",
    phone: "1234567890",
  };

  const mockWorkOrder = {
    id: "55555555-5555-5555-8555-555555555555",
    code: "WO-0001",
    issueId: mockIssue.id,
    maintenanceDepartmentId: mockDepartment.id,
    assignedToExternalUserId: "tech-user-101",
    priority: WorkOrderPriority.MEDIUM,
    status: WorkOrderStatus.SCHEDULED,
    issue: mockIssue,
    maintenanceDepartment: mockDepartment,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Specs ───────────────────────────────────────────────────
  describe("WorkOrderRepository Unit Specs", () => {
    it("findAll() should query active work orders with search, filters, pagination, and newest-first order", async () => {
      jest.spyOn(prisma.workOrder, "findMany").mockResolvedValue([mockWorkOrder]);
      jest.spyOn(prisma.workOrder, "count").mockResolvedValue(1);

      const result = await workOrderRepository.findAll({
        page: 1,
        limit: 10,
        search: "WO-0001",
        issueId: mockIssue.id,
        maintenanceDepartmentId: mockDepartment.id,
        priority: WorkOrderPriority.MEDIUM,
        status: WorkOrderStatus.SCHEDULED,
      });

      expect(prisma.workOrder.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
          where: expect.objectContaining({
            deletedAt: null,
            issueId: mockIssue.id,
            maintenanceDepartmentId: mockDepartment.id,
            priority: WorkOrderPriority.MEDIUM,
            status: WorkOrderStatus.SCHEDULED,
            OR: [
              { code: { contains: "WO-0001", mode: "insensitive" } },
              { issue: { title: { contains: "WO-0001", mode: "insensitive" } } },
            ],
          }),
          orderBy: [{ createdAt: "desc" }],
        })
      );
      expect(result.data).toEqual([mockWorkOrder]);
      expect(result.meta.total).toBe(1);
    });

    it("findById() should query active work order by ID", async () => {
      jest.spyOn(prisma.workOrder, "findFirst").mockResolvedValue(mockWorkOrder);

      const result = await workOrderRepository.findById(mockWorkOrder.id);

      expect(prisma.workOrder.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockWorkOrder.id, deletedAt: null },
        })
      );
      expect(result).toEqual(mockWorkOrder);
    });

    it("findByCode() should query active work order by code", async () => {
      jest.spyOn(prisma.workOrder, "findFirst").mockResolvedValue(mockWorkOrder);

      const result = await workOrderRepository.findByCode("WO-0001");

      expect(prisma.workOrder.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { code: "WO-0001", deletedAt: null },
        })
      );
      expect(result).toEqual(mockWorkOrder);
    });

    it("create() should persist a new work order record", async () => {
      jest.spyOn(prisma.workOrder, "create").mockResolvedValue(mockWorkOrder);

      const result = await workOrderRepository.create({
        code: "WO-0001",
        issueId: mockIssue.id,
        maintenanceDepartmentId: mockDepartment.id,
      });

      expect(prisma.workOrder.create).toHaveBeenCalled();
      expect(result).toEqual(mockWorkOrder);
    });

    it("update() should modify an existing work order record", async () => {
      const updatedMock = { ...mockWorkOrder, status: WorkOrderStatus.IN_PROGRESS };
      jest.spyOn(prisma.workOrder, "update").mockResolvedValue(updatedMock);

      const result = await workOrderRepository.update(mockWorkOrder.id, { status: WorkOrderStatus.IN_PROGRESS });

      expect(prisma.workOrder.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockWorkOrder.id },
          data: { status: WorkOrderStatus.IN_PROGRESS },
        })
      );
      expect(result.status).toBe(WorkOrderStatus.IN_PROGRESS);
    });

    it("delete() should soft-delete work order by setting deletedAt timestamp", async () => {
      const deletedMock = { ...mockWorkOrder, deletedAt: new Date() };
      jest.spyOn(prisma.workOrder, "update").mockResolvedValue(deletedMock);

      const result = await workOrderRepository.delete(mockWorkOrder.id);

      expect(prisma.workOrder.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockWorkOrder.id },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        })
      );
      expect(result.deletedAt).toBeDefined();
    });
  });

  // ─── 2. Service Unit Specs ─────────────────────────────────────────────────
  describe("WorkOrderService Unit Specs", () => {
    it("generateWorkOrderCode() should auto-generate sequential code starting at WO-0001", async () => {
      jest.spyOn(workOrderRepository, "findLatest").mockResolvedValue(null);
      jest.spyOn(workOrderRepository, "findByCode").mockResolvedValue(null);

      const code = await workOrderService.generateWorkOrderCode();
      expect(code).toBe("WO-0001");
    });

    it("createWorkOrder() should assign default status SCHEDULED and priority MEDIUM", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(prisma.maintenanceDepartment, "findFirst").mockResolvedValue(mockDepartment);
      jest.spyOn(workOrderRepository, "findLatest").mockResolvedValue(null);
      jest.spyOn(workOrderRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(workOrderRepository, "create").mockImplementation(async (data) => ({
        ...mockWorkOrder,
        ...data,
      }));

      const payload = {
        issueId: mockIssue.id,
        maintenanceDepartmentId: mockDepartment.id,
      };

      const result = await workOrderService.createWorkOrder(payload);

      expect(result.code).toBe("WO-0001");
      expect(result.priority).toBe(WorkOrderPriority.MEDIUM);
      expect(result.status).toBe(WorkOrderStatus.SCHEDULED);
    });

    it("createWorkOrder() should throw 404 when issueId does not exist", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(null);

      await expect(
        workOrderService.createWorkOrder({
          issueId: "00000000-0000-0000-0000-000000000000",
          maintenanceDepartmentId: mockDepartment.id,
        })
      ).rejects.toThrow("Issue with ID 00000000-0000-0000-0000-000000000000 not found");
    });

    it("createWorkOrder() should throw 404 when maintenanceDepartmentId does not exist", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(prisma.maintenanceDepartment, "findFirst").mockResolvedValue(null);

      await expect(
        workOrderService.createWorkOrder({
          issueId: mockIssue.id,
          maintenanceDepartmentId: "00000000-0000-0000-0000-000000000000",
        })
      ).rejects.toThrow("Maintenance department with ID 00000000-0000-0000-0000-000000000000 not found");
    });
  });

  // ─── 3. Route & Controller Integration Specs ──────────────────────────────
  describe("WorkOrder API Routes (/api/v1/work-orders)", () => {
    it("GET /api/v1/work-orders should return 200 with paginated active work orders and rich response", async () => {
      jest.spyOn(workOrderRepository, "findAll").mockResolvedValue({
        data: [mockWorkOrder],
        meta: { page: 1, limit: 10, total: 1, totalPages: 1, hasNext: false, hasPrevious: false },
      });

      const response = await request(app).get("/api/v1/work-orders").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual([JSON.parse(JSON.stringify(mockWorkOrder))]);
      expect(response.body.meta.total).toBe(1);
    });

    it("GET /api/v1/work-orders/:id should return work order details when found", async () => {
      jest.spyOn(workOrderRepository, "findById").mockResolvedValue(mockWorkOrder);

      const response = await request(app).get(`/api/v1/work-orders/${mockWorkOrder.id}`).expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(mockWorkOrder.id);
    });

    it("GET /api/v1/work-orders/:id should return 404 when work order is missing", async () => {
      jest.spyOn(workOrderRepository, "findById").mockResolvedValue(null);

      const response = await request(app)
        .get("/api/v1/work-orders/00000000-0000-0000-0000-000000000000")
        .expect(404);

      expect(response.body.success).toBe(false);
    });

    it("POST /api/v1/work-orders should create work order and return 201", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(prisma.maintenanceDepartment, "findFirst").mockResolvedValue(mockDepartment);
      jest.spyOn(workOrderRepository, "findLatest").mockResolvedValue(null);
      jest.spyOn(workOrderRepository, "findByCode").mockResolvedValue(null);
      jest.spyOn(workOrderRepository, "create").mockResolvedValue(mockWorkOrder);

      const response = await request(app)
        .post("/api/v1/work-orders")
        .send({
          issueId: mockIssue.id,
          maintenanceDepartmentId: mockDepartment.id,
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.code).toBe("WO-0001");
    });

    it("POST /api/v1/work-orders should return 400 when validation fails (invalid issueId UUID)", async () => {
      const response = await request(app)
        .post("/api/v1/work-orders")
        .send({
          issueId: "invalid-uuid",
          maintenanceDepartmentId: mockDepartment.id,
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("PUT /api/v1/work-orders/:id should update work order details", async () => {
      const updatedWorkOrder = { ...mockWorkOrder, status: WorkOrderStatus.IN_PROGRESS };
      jest.spyOn(workOrderRepository, "findById").mockResolvedValue(mockWorkOrder);
      jest.spyOn(workOrderRepository, "update").mockResolvedValue(updatedWorkOrder);

      const response = await request(app)
        .put(`/api/v1/work-orders/${mockWorkOrder.id}`)
        .send({ status: WorkOrderStatus.IN_PROGRESS })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe(WorkOrderStatus.IN_PROGRESS);
    });

    it("DELETE /api/v1/work-orders/:id should soft delete work order", async () => {
      jest.spyOn(workOrderRepository, "findById").mockResolvedValue(mockWorkOrder);
      jest.spyOn(workOrderRepository, "delete").mockResolvedValue(mockWorkOrder);

      const response = await request(app).delete(`/api/v1/work-orders/${mockWorkOrder.id}`).expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.deleted).toBe(true);
    });
  });
});
