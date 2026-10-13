// Set dummy connection strings FIRST before any module imports or client instantiation
process.env.DATABASE_URL = "postgresql://test:test@127.0.0.1:1/infracare_test?schema=public";
process.env.DIRECT_URL = "postgresql://test:test@127.0.0.1:1/infracare_test?schema=public";
process.env.NODE_ENV = "test";
process.env.PORT = "5051";
process.env.JWT_SECRET = "test-jwt-secret-key-12345";

import { jest } from "@jest/globals";

beforeAll(() => {
  // Global beforeAll setup
});

afterAll(async () => {
  // Global afterAll teardown
});
