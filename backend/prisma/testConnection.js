import { prisma } from "./client.js";

async function main() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    console.log("✅ Prisma successfully connected to PostgreSQL!");
  } catch (error) {
    console.error("❌ Prisma connection to PostgreSQL failed:", error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main();
