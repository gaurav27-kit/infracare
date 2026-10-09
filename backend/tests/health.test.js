import request from "supertest";
import app from "../src/app.js";
import campusRepository from "../src/repositories/campus/campus.repository.js";
import { jest } from "@jest/globals";

describe("Health API Endpoint", () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("GET /api/v1/health should return health status object including campusConfigured", async () => {
    jest.spyOn(campusRepository, "exists").mockResolvedValue(true);

    const res = await request(app).get("/api/v1/health");
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("success", true);
    expect(res.body).toHaveProperty("data");
    expect(res.body.data).toHaveProperty("service", "smart-campus-backend");
    expect(res.body.data).toHaveProperty("campusConfigured", true);
    expect(res.body.data).toHaveProperty("database");
  });

  it("GET /api/v1/unknown-route should return 404 ApiError", async () => {
    const res = await request(app).get("/api/v1/unknown-route");
    expect(res.statusCode).toBe(404);
    expect(res.body).toHaveProperty("success", false);
  });
});
