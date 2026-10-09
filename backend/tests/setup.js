import { jest } from "@jest/globals";

process.env.NODE_ENV = "test";
process.env.PORT = "5001";
process.env.JWT_SECRET = "test-jwt-secret-key-12345";

beforeAll(() => {
  // Global beforeAll setup if needed
});

afterAll(async () => {
  // Global afterAll teardown if needed
});
