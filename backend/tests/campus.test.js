import request from "supertest";
import app from "../src/app.js";
import campusRepository from "../src/repositories/campus/campus.repository.js";
import { jest } from "@jest/globals";

describe("Single Campus API Module (/api/v1/campus)", () => {
  const mockCampus = {
    id: "11111111-2222-3333-4444-555555555555",
    name: "ABC Engineering College",
    code: "ABC",
    description: "Main Campus of ABC Engineering College",
    address: "123 University Avenue, Tech City, ST 56001",
    phone: "+1-800-555-0199",
    email: "info@abc-college.edu",
    website: "https://abc-college.edu",
    logoUrl: "https://abc-college.edu/assets/logo.png",
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe("GET /api/v1/campus", () => {
    it("should return the single campus record when it exists", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(mockCampus);

      const res = await request(app).get("/api/v1/campus");

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Campus details retrieved successfully");
      expect(res.body.data.name).toBe("ABC Engineering College");
      expect(res.body.data.code).toBe("ABC");
    });

    it("should return 404 when campus record is missing", async () => {
      jest.spyOn(campusRepository, "findCampus").mockResolvedValue(null);

      const res = await request(app).get("/api/v1/campus");

      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/not found/i);
    });
  });

  describe("PUT /api/v1/campus", () => {
    it("should update campus details without requiring campus ID in request", async () => {
      const updateData = {
        name: "ABC Institute of Technology",
        phone: "+1-800-555-9999",
        email: "contact@abc-tech.edu",
      };

      const updatedMockCampus = {
        ...mockCampus,
        ...updateData,
      };

      jest.spyOn(campusRepository, "exists").mockResolvedValue(true);
      jest.spyOn(campusRepository, "updateCampus").mockResolvedValue(updatedMockCampus);

      const res = await request(app).put("/api/v1/campus").send(updateData);

      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toBe("Campus details updated successfully");
      expect(res.body.data.name).toBe("ABC Institute of Technology");
      expect(res.body.data.email).toBe("contact@abc-tech.edu");
    });

    it("should return 400 bad request when validation fails (invalid email)", async () => {
      const invalidData = {
        email: "not-an-email",
      };

      const res = await request(app).put("/api/v1/campus").send(invalidData);

      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toMatch(/validation error/i);
    });
  });
});
