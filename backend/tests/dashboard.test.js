import request from "supertest";
import app from "../src/app.js";
import dashboardRepository from "../src/repositories/dashboard/dashboard.repository.js";
import dashboardService from "../src/services/dashboard.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";
import { IssueStatus, IssuePriority, AssetStatus } from "../src/types/enums.js";

describe("Dashboard Module Tests", () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Specs ───────────────────────────────────────────────────
  describe("DashboardRepository Unit Specs", () => {
    it("getSummary() should return active campus details and entity counts", async () => {
      jest.spyOn(prisma.campus, "findFirst").mockResolvedValue({ name: "Main Campus", code: "MAIN-01" });
      jest.spyOn(prisma.building, "count").mockResolvedValue(6);
      jest.spyOn(prisma.floor, "count").mockResolvedValue(18);
      jest.spyOn(prisma.space, "count").mockResolvedValue(74);
      jest.spyOn(prisma.asset, "count").mockResolvedValue(310);
      jest.spyOn(prisma.issue, "count").mockResolvedValue(27);
      jest.spyOn(prisma.workOrder, "count").mockResolvedValue(15);

      const result = await dashboardRepository.getSummary();

      expect(result.campus).toEqual({ name: "Main Campus", code: "MAIN-01" });
      expect(result.counts).toEqual({
        buildings: 6,
        floors: 18,
        spaces: 74,
        assets: 310,
        issues: 27,
        workOrders: 15,
      });
    });

    it("getIssueStatistics() should aggregate issue counts by status and priority", async () => {
      jest.spyOn(prisma.issue, "groupBy").mockImplementation(async ({ by }) => {
        if (by.includes("status")) {
          return [{ status: IssueStatus.OPEN, _count: { status: 10 } }];
        }
        if (by.includes("priority")) {
          return [{ priority: IssuePriority.HIGH, _count: { priority: 11 } }];
        }
        return [];
      });

      const { statusGroup, priorityGroup } = await dashboardRepository.getIssueStatistics();

      expect(statusGroup).toEqual([{ status: IssueStatus.OPEN, _count: { status: 10 } }]);
      expect(priorityGroup).toEqual([{ priority: IssuePriority.HIGH, _count: { priority: 11 } }]);
    });

    it("getAssetStatistics() should aggregate asset counts by status", async () => {
      jest.spyOn(prisma.asset, "groupBy").mockResolvedValue([
        { status: AssetStatus.OPERATIONAL, _count: { status: 240 } },
      ]);

      const result = await dashboardRepository.getAssetStatistics();

      expect(result).toEqual([{ status: AssetStatus.OPERATIONAL, _count: { status: 240 } }]);
    });

    it("getMaintenanceOverview() should count open issues and work order status categories", async () => {
      jest.spyOn(prisma.issue, "count").mockResolvedValue(18);
      jest.spyOn(prisma.workOrder, "count").mockImplementation(async ({ where }) => {
        if (where.status === "SCHEDULED") return 6;
        if (where.status === "IN_PROGRESS") return 4;
        if (where.status === "COMPLETED") return 12;
        return 0;
      });

      const result = await dashboardRepository.getMaintenanceOverview();

      expect(result).toEqual({
        openIssues: 18,
        scheduledWorkOrders: 6,
        inProgressWorkOrders: 4,
        completedWorkOrders: 12,
      });
    });

    it("getRecentIssues() should return top 5 latest active issues", async () => {
      const mockIssue = {
        id: "issue-1",
        issueNumber: "ISS-0001",
        title: "Leakage",
        priority: "HIGH",
        status: "OPEN",
        createdAt: new Date().toISOString(),
        space: { name: "Lab A", floor: { building: { name: "Block A" } } },
      };
      jest.spyOn(prisma.issue, "findMany").mockResolvedValue([mockIssue]);

      const result = await dashboardRepository.getRecentIssues();

      expect(prisma.issue.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          take: 5,
          where: { deletedAt: null },
          orderBy: { createdAt: "desc" },
        })
      );
      expect(result).toEqual([mockIssue]);
    });

    it("getRecentWorkOrders() should return top 5 latest active work orders", async () => {
      const mockWo = {
        id: "wo-1",
        code: "WO-0001",
        status: "SCHEDULED",
        priority: "MEDIUM",
        createdAt: new Date().toISOString(),
        issue: { issueNumber: "ISS-0001", title: "Leakage" },
        maintenanceDepartment: { name: "Civil & Plumbing" },
      };
      jest.spyOn(prisma.workOrder, "findMany").mockResolvedValue([mockWo]);

      const result = await dashboardRepository.getRecentWorkOrders();

      expect(prisma.workOrder.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          take: 5,
          where: { deletedAt: null },
          orderBy: { createdAt: "desc" },
        })
      );
      expect(result).toEqual([mockWo]);
    });
  });

  // ─── 2. Service Specs ─────────────────────────────────────────────────────
  describe("DashboardService Specs", () => {
    it("getIssueStatistics() should include all enum keys with zero defaults", async () => {
      jest.spyOn(dashboardRepository, "getIssueStatistics").mockResolvedValue({
        statusGroup: [{ status: IssueStatus.OPEN, _count: { status: 5 } }],
        priorityGroup: [{ priority: IssuePriority.HIGH, _count: { priority: 3 } }],
      });

      const result = await dashboardService.getIssueStatistics();

      expect(result.status).toEqual({
        OPEN: 5,
        ASSIGNED: 0,
        IN_PROGRESS: 0,
        RESOLVED: 0,
        CLOSED: 0,
      });

      expect(result.priority).toEqual({
        LOW: 0,
        MEDIUM: 0,
        HIGH: 3,
        CRITICAL: 0,
      });
    });

    it("getAssetStatistics() should include all asset status enum keys with zero defaults", async () => {
      jest.spyOn(dashboardRepository, "getAssetStatistics").mockResolvedValue([
        { status: AssetStatus.OPERATIONAL, _count: { status: 120 } },
      ]);

      const result = await dashboardService.getAssetStatistics();

      expect(result.status).toEqual({
        OPERATIONAL: 120,
        FAULTY: 0,
        UNDER_MAINTENANCE: 0,
        DECOMMISSIONED: 0,
      });
    });
  });

  // ─── 3. API Integration Specs ─────────────────────────────────────────────
  describe("Dashboard API Integration Routes (/api/v1/dashboard)", () => {
    it("GET /api/v1/dashboard/summary should return 200 OK with summary data", async () => {
      jest.spyOn(dashboardRepository, "getSummary").mockResolvedValue({
        campus: { name: "Main Campus", code: "MAIN-01" },
        counts: { buildings: 6, floors: 18, spaces: 74, assets: 310, issues: 27, workOrders: 15 },
      });

      const response = await request(app).get("/api/v1/dashboard/summary").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.campus.code).toBe("MAIN-01");
      expect(response.body.data.counts.assets).toBe(310);
    });

    it("GET /api/v1/dashboard/summary should handle empty database gracefully (HTTP 200)", async () => {
      jest.spyOn(dashboardRepository, "getSummary").mockResolvedValue({
        campus: { name: "", code: "" },
        counts: { buildings: 0, floors: 0, spaces: 0, assets: 0, issues: 0, workOrders: 0 },
      });

      const response = await request(app).get("/api/v1/dashboard/summary").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.counts.buildings).toBe(0);
    });

    it("GET /api/v1/dashboard/issues should return 200 OK with complete enum maps", async () => {
      jest.spyOn(dashboardRepository, "getIssueStatistics").mockResolvedValue({
        statusGroup: [],
        priorityGroup: [],
      });

      const response = await request(app).get("/api/v1/dashboard/issues").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status.OPEN).toBe(0);
      expect(response.body.data.priority.CRITICAL).toBe(0);
    });

    it("GET /api/v1/dashboard/assets should return 200 OK with complete status map", async () => {
      jest.spyOn(dashboardRepository, "getAssetStatistics").mockResolvedValue([]);

      const response = await request(app).get("/api/v1/dashboard/assets").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.status.OPERATIONAL).toBe(0);
    });

    it("GET /api/v1/dashboard/maintenance should return 200 OK with maintenance counts", async () => {
      jest.spyOn(dashboardRepository, "getMaintenanceOverview").mockResolvedValue({
        openIssues: 18,
        scheduledWorkOrders: 6,
        inProgressWorkOrders: 4,
        completedWorkOrders: 12,
      });

      const response = await request(app).get("/api/v1/dashboard/maintenance").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.openIssues).toBe(18);
    });

    it("GET /api/v1/dashboard/recent-issues should return 200 OK with top 5 issues", async () => {
      jest.spyOn(dashboardRepository, "getRecentIssues").mockResolvedValue([
        {
          id: "issue-1",
          issueNumber: "ISS-0001",
          title: "Leakage",
          priority: "HIGH",
          status: "OPEN",
          createdAt: new Date().toISOString(),
          space: { name: "Lab A", floor: { building: { name: "Block A" } } },
        },
      ]);

      const response = await request(app).get("/api/v1/dashboard/recent-issues").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data[0].issueNumber).toBe("ISS-0001");
      expect(response.body.data[0].building.name).toBe("Block A");
    });

    it("GET /api/v1/dashboard/recent-work-orders should return 200 OK with top 5 work orders", async () => {
      jest.spyOn(dashboardRepository, "getRecentWorkOrders").mockResolvedValue([
        {
          id: "wo-1",
          code: "WO-0001",
          status: "SCHEDULED",
          priority: "MEDIUM",
          createdAt: new Date().toISOString(),
          issue: { issueNumber: "ISS-0001", title: "Leakage" },
          maintenanceDepartment: { name: "Civil & Plumbing" },
        },
      ]);

      const response = await request(app).get("/api/v1/dashboard/recent-work-orders").expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data[0].code).toBe("WO-0001");
      expect(response.body.data[0].issueNumber).toBe("ISS-0001");
      expect(response.body.data[0].maintenanceDepartment).toBe("Civil & Plumbing");
    });
  });
});
