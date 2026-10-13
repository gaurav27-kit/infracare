/**
 * @file sync_to_supabase.js
 * @description Migrates master data and issues to a Supabase PostgreSQL instance.
 *
 * Usage:
 *   $env:DATABASE_URL="postgresql://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres"
 *   node prisma/sync_to_supabase.js
 */

import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import {
  seedCampus,
  seedBuildings,
  seedFloors,
  seedSpaces,
  seedAssetCategories,
  seedAssets,
  seedMaintenanceDepartments,
  verifySeedData,
} from "./seed.js";

const prisma = new PrismaClient();

const sampleIssues = [
  {
    issueNumber: "ISS-0001",
    spaceCode: "APPLE-LAB",
    customAssetName: null,
    title: "Test Lab iMac monitor flicker",
    description: "Monitor flickers intermittently when booting up.",
    priority: "HIGH",
    status: "OPEN",
    reporterExternalUserId: "student-user-1",
    attachments: [],
  },
  {
    issueNumber: "ISS-0002",
    spaceCode: "CSAM-CR-01",
    customAssetName: "Water Tap",
    title: "Water tap leaking heavily",
    description: "Continuous leakage in washroom fixture",
    priority: "MEDIUM",
    status: "OPEN",
    reporterExternalUserId: "ext-user-1",
    attachments: [],
  },
  {
    issueNumber: "ISS-0003",
    spaceCode: "CSAM-LAB-04",
    customAssetName: null,
    title: "broken ac",
    description: "ac was broken by some students",
    priority: "HIGH",
    status: "ASSIGNED",
    reporterExternalUserId: "ext-user-1",
    attachments: [
      {
        fileName: "test_ac.png",
        fileUrl: "https://res.cloudinary.com/t8vzc5br/image/upload/v1791463662/SCMS/issues/xhe5xr5nabhl4kflm7mj.png",
        fileType: "image/png",
      },
    ],
  },
  {
    issueNumber: "ISS-0004",
    spaceCode: "ETCR-04", // Room code for CBCR-06
    customAssetName: "AST-ELEC-PANEL",
    title: "electrical panel issues",
    description: "electrical objectives issues",
    priority: "MEDIUM",
    status: "RESOLVED",
    reporterExternalUserId: "ext-user-1",
    attachments: [
      {
        fileName: "scaled_Leetcode Contest.png",
        fileUrl: "https://res.cloudinary.com/t8vzc5br/image/upload/v1791479617/SCMS/issues/srgws6adpke6x6pjyviw.png",
        fileType: "image/png",
      },
    ],
  },
];

async function seedIssues(spacesMap) {
  console.log("[SYNC] Seeding sample issues...");
  for (const item of sampleIssues) {
    const space = spacesMap[item.spaceCode];
    if (!space) {
      console.warn(`[SYNC] Space ${item.spaceCode} not found for issue ${item.issueNumber}`);
      continue;
    }

    // Check if issue already exists by issueNumber
    const existing = await prisma.issue.findFirst({
      where: { issueNumber: item.issueNumber },
    });

    let issueId;
    if (existing) {
      await prisma.issue.update({
        where: { id: existing.id },
        data: {
          title: item.title,
          description: item.description,
          priority: item.priority,
          status: item.status,
          spaceId: space.id,
          customAssetName: item.customAssetName,
        },
      });
      issueId = existing.id;
      console.log(`[SYNC] ℹ️ Updated issue: ${item.issueNumber} - ${item.title}`);
    } else {
      const created = await prisma.issue.create({
        data: {
          issueNumber: item.issueNumber,
          spaceId: space.id,
          customAssetName: item.customAssetName,
          title: item.title,
          description: item.description,
          priority: item.priority,
          status: item.status,
          reporterExternalUserId: item.reporterExternalUserId,
        },
      });
      issueId = created.id;
      console.log(`[SYNC] ✅ Created issue: ${item.issueNumber} - ${item.title}`);
    }

    // Upsert attachments
    for (const att of item.attachments) {
      const existingAtt = await prisma.issueAttachment.findFirst({
        where: { issueId, fileUrl: att.fileUrl },
      });
      if (!existingAtt) {
        await prisma.issueAttachment.create({
          data: {
            issueId,
            fileName: att.fileName,
            fileUrl: att.fileUrl,
            fileType: att.fileType,
          },
        });
        console.log(`[SYNC]   📎 Added attachment: ${att.fileName}`);
      }
    }
  }
}

async function main() {
  console.log("==================================================");
  console.log("   INFRACARE — SUPABASE POSTGRESQL SYNC           ");
  console.log("==================================================");
  console.log(`Connecting to: ${process.env.DATABASE_URL?.split("@")[1] || "configured DATABASE_URL"}\n`);

  const campus = await seedCampus();
  const buildingsMap = await seedBuildings(campus.id);
  const floorsMap = await seedFloors(buildingsMap);
  const spacesMap = await seedSpaces(floorsMap);
  const categoriesMap = await seedAssetCategories();
  await seedAssets(spacesMap, categoriesMap);
  await seedMaintenanceDepartments();
  await seedIssues(spacesMap);
  await verifySeedData();

  const totalIssues = await prisma.issue.count();
  console.log(`  ✓ Total Issues in Database    : ${totalIssues}`);
  console.log("==================================================");
  console.log("✅ Supabase sync complete! Both spaces and issues are populated.\n");
}

main()
  .catch((e) => {
    console.error("[SYNC ERROR] Migration failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
