/**
 * @file campusSeeder.js
 * @description Wrapper forwarding campus seeding to standard Prisma seed module.
 */

import { seedCampus, main } from "../../prisma/seed.js";

export const seedCampusData = async () => {
  await main();
  return seedCampus();
};
