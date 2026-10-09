import request from "supertest";
import app from "../src/app.js";
import issueAttachmentRepository from "../src/repositories/issueAttachment/issueAttachment.repository.js";
import issueRepository from "../src/repositories/issue/issue.repository.js";
import issueAttachmentService from "../src/services/issueAttachment.service.js";
import prisma from "../src/config/prisma.js";
import { jest } from "@jest/globals";

describe("IssueAttachment Module Tests", () => {
  const mockIssue = {
    id: "33333333-3333-4333-8333-333333333333",
    issueNumber: "ISS-0001",
    title: "Water Leakage Near Projector",
    description: "Ceiling water leakage noticed above the projector in Seminar Hall A1.",
  };

  const mockAttachment = {
    id: "66666666-6666-6666-8666-666666666666",
    issueId: mockIssue.id,
    fileName: "leakage_photo.jpg",
    fileUrl: "https://storage.campus.edu/uploads/leakage_photo.jpg",
    fileType: "image/jpeg",
    uploadedAt: new Date().toISOString(),
    issue: {
      issueNumber: mockIssue.issueNumber,
      title: mockIssue.title,
    },
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // ─── 1. Repository Specs ───────────────────────────────────────────────────
  describe("IssueAttachmentRepository Unit Specs", () => {
    it("findByIssue() should return attachments belonging to issue", async () => {
      jest.spyOn(prisma.issueAttachment, "findMany").mockResolvedValue([mockAttachment]);

      const result = await issueAttachmentRepository.findByIssue(mockIssue.id);

      expect(prisma.issueAttachment.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { issueId: mockIssue.id },
        })
      );
      expect(result).toEqual([mockAttachment]);
    });

    it("findById() should return attachment by ID", async () => {
      jest.spyOn(prisma.issueAttachment, "findFirst").mockResolvedValue(mockAttachment);

      const result = await issueAttachmentRepository.findById(mockAttachment.id);

      expect(prisma.issueAttachment.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: mockAttachment.id },
        })
      );
      expect(result).toEqual(mockAttachment);
    });

    it("create() should persist attachment record", async () => {
      jest.spyOn(prisma.issueAttachment, "create").mockResolvedValue(mockAttachment);

      const result = await issueAttachmentRepository.create({
        issueId: mockIssue.id,
        fileName: mockAttachment.fileName,
        fileUrl: mockAttachment.fileUrl,
        fileType: mockAttachment.fileType,
      });

      expect(prisma.issueAttachment.create).toHaveBeenCalled();
      expect(result).toEqual(mockAttachment);
    });

    it("delete() should delete attachment record by ID", async () => {
      jest.spyOn(prisma.issueAttachment, "delete").mockResolvedValue(mockAttachment);

      const result = await issueAttachmentRepository.delete(mockAttachment.id);

      expect(prisma.issueAttachment.delete).toHaveBeenCalledWith({
        where: { id: mockAttachment.id },
      });
      expect(result).toEqual(mockAttachment);
    });
  });

  // ─── 2. Service Unit Specs ─────────────────────────────────────────────────
  describe("IssueAttachmentService Unit Specs", () => {
    it("getAttachmentsByIssue() should throw 404 when issue does not exist", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(null);

      await expect(
        issueAttachmentService.getAttachmentsByIssue("00000000-0000-0000-0000-000000000000")
      ).rejects.toThrow("Issue with ID 00000000-0000-0000-0000-000000000000 not found");
    });

    it("createAttachment() should throw 404 when issue does not exist", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(null);

      await expect(
        issueAttachmentService.createAttachment("00000000-0000-0000-0000-000000000000", {
          fileName: "photo.jpg",
          fileUrl: "https://storage.com/photo.jpg",
          fileType: "image/jpeg",
        })
      ).rejects.toThrow("Issue with ID 00000000-0000-0000-0000-000000000000 not found");
    });

    it("deleteAttachment() should throw 404 when attachment does not exist", async () => {
      jest.spyOn(issueAttachmentRepository, "findById").mockResolvedValue(null);

      await expect(
        issueAttachmentService.deleteAttachment("00000000-0000-0000-0000-000000000000")
      ).rejects.toThrow("Attachment with ID 00000000-0000-0000-0000-000000000000 not found");
    });
  });

  // ─── 3. Route & Controller Integration Specs ──────────────────────────────
  describe("IssueAttachment API Routes", () => {
    it("GET /api/v1/issues/:issueId/attachments should return 200 with attachments list", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(issueAttachmentRepository, "findByIssue").mockResolvedValue([mockAttachment]);

      const response = await request(app)
        .get(`/api/v1/issues/${mockIssue.id}/attachments`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual([JSON.parse(JSON.stringify(mockAttachment))]);
    });

    it("POST /api/v1/issues/:issueId/attachments should create attachment and return 201", async () => {
      jest.spyOn(issueRepository, "findById").mockResolvedValue(mockIssue);
      jest.spyOn(issueAttachmentRepository, "create").mockResolvedValue(mockAttachment);

      const response = await request(app)
        .post(`/api/v1/issues/${mockIssue.id}/attachments`)
        .send({
          fileName: "leakage_photo.jpg",
          fileUrl: "https://storage.campus.edu/uploads/leakage_photo.jpg",
          fileType: "image/jpeg",
        })
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data.fileName).toBe("leakage_photo.jpg");
    });

    it("POST /api/v1/issues/:issueId/attachments should return 400 when validation fails (missing fileName)", async () => {
      const response = await request(app)
        .post(`/api/v1/issues/${mockIssue.id}/attachments`)
        .send({
          fileUrl: "https://storage.campus.edu/uploads/leakage_photo.jpg",
          fileType: "image/jpeg",
        })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it("DELETE /api/v1/attachments/:id should delete attachment", async () => {
      jest.spyOn(issueAttachmentRepository, "findById").mockResolvedValue(mockAttachment);
      jest.spyOn(issueAttachmentRepository, "delete").mockResolvedValue(mockAttachment);

      const response = await request(app).delete(`/api/v1/attachments/${mockAttachment.id}`).expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.deleted).toBe(true);
    });
  });
});
