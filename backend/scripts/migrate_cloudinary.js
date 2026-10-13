/**
 * @file migrate_cloudinary.js
 * @description Safe, idempotent migration utility to transition InfraCare issue attachments
 * from the shared Cloudinary account to a dedicated InfraCare Cloudinary account.
 *
 * Requirements:
 * - Does NOT delete any source Cloudinary assets (leaves SCMC untouched).
 * - Copies assets directly via Cloudinary URL upload API to the dedicated account.
 * - Supports dry-run mode by default (pass --execute to apply changes).
 * - Verifies HTTP accessibility of new URLs before updating PostgreSQL records.
 * - Idempotent: Skips records already pointing to the new Cloudinary account.
 *
 * Usage:
 *   node scripts/migrate_cloudinary.js           # Dry-run mode
 *   node scripts/migrate_cloudinary.js --dry-run # Explicit dry-run
 *   node scripts/migrate_cloudinary.js --execute # Live migration (requires explicit approval)
 */

import { v2 as cloudinary } from "cloudinary";
import https from "https";
import http from "http";
import fs from "fs";
import path from "path";
import prisma from "../src/config/prisma.js";
import logger from "../src/utils/logger.js";

// Load configuration
const isExecute = process.argv.includes("--execute");
const isDryRun = !isExecute || process.argv.includes("--dry-run");

const OLD_CLOUD_NAME = process.env.OLD_CLOUDINARY_CLOUD_NAME || "t8vzc5br";
const NEW_CLOUD_NAME = process.env.NEW_CLOUDINARY_CLOUD_NAME || process.env.CLOUDINARY_CLOUD_NAME;
const NEW_API_KEY = process.env.NEW_CLOUDINARY_API_KEY || process.env.CLOUDINARY_API_KEY;
const NEW_API_SECRET = process.env.NEW_CLOUDINARY_API_SECRET || process.env.CLOUDINARY_API_SECRET;
const TARGET_FOLDER = process.env.CLOUDINARY_FOLDER || "infracare/issues";

// Verify HTTP URL accessibility helper
const verifyUrlAccessible = (url) => {
  return new Promise((resolve) => {
    try {
      const client = url.startsWith("https") ? https : http;
      client.get(url, (res) => {
        resolve(res.statusCode >= 200 && res.statusCode < 400);
      }).on("error", () => {
        resolve(false);
      });
    } catch {
      resolve(false);
    }
  });
};

async function runMigration() {
  console.log("============================================================");
  console.log(" InfraCare Cloudinary Isolation & Migration Tool");
  console.log(" Mode: " + (isDryRun ? "DRY RUN (Read-Only - No DB or Asset Changes)" : "EXECUTE (Live Migration)"));
  console.log(" Source Cloud Name : " + OLD_CLOUD_NAME);
  console.log(" Target Cloud Name : " + (NEW_CLOUD_NAME || "[NOT CONFIGURED]"));
  console.log(" Target Folder     : " + TARGET_FOLDER);
  console.log("============================================================");

  if (!isDryRun) {
    if (!NEW_CLOUD_NAME || !NEW_API_KEY || !NEW_API_SECRET) {
      console.error("ERROR: Dedicated Cloudinary credentials not configured.");
      console.error("Set NEW_CLOUDINARY_CLOUD_NAME, NEW_CLOUDINARY_API_KEY, and NEW_CLOUDINARY_API_SECRET.");
      process.exit(1);
    }
    if (NEW_CLOUD_NAME === OLD_CLOUD_NAME) {
      console.error("ERROR: Target cloud name cannot be identical to the shared old cloud name.");
      process.exit(1);
    }
  }

  // Initialize target Cloudinary client
  const targetCloudinary = cloudinary;
  if (!isDryRun) {
    targetCloudinary.config({
      cloud_name: NEW_CLOUD_NAME,
      api_key: NEW_API_KEY,
      api_secret: NEW_API_SECRET,
    });
  }

  // Query all attachment records
  console.log("\n[1/4] Scanning database for IssueAttachment records...");
  const attachments = await prisma.issueAttachment.findMany({
    select: {
      id: true,
      issueId: true,
      fileName: true,
      fileUrl: true,
      fileType: true,
      uploadedAt: true,
    },
    orderBy: { uploadedAt: "asc" },
  });

  console.log(`Found ${attachments.length} total attachment record(s).`);

  const summary = {
    total: attachments.length,
    alreadyMigrated: 0,
    nonCloudinary: 0,
    eligibleToMigrate: 0,
    successfullyMigrated: 0,
    failed: 0,
  };

  const mappingAudit = [];

  console.log("\n[2/4] Analyzing attachment source URLs...");

  for (const record of attachments) {
    const url = record.fileUrl || "";

    // Check if already using new cloud name
    if (NEW_CLOUD_NAME && url.includes(`res.cloudinary.com/${NEW_CLOUD_NAME}/`)) {
      summary.alreadyMigrated++;
      console.log(`- [ALREADY MIGRATED] ID: ${record.id} (${record.fileName})`);
      continue;
    }

    // Check if hosted on shared old cloud
    if (url.includes(`res.cloudinary.com/${OLD_CLOUD_NAME}/`)) {
      summary.eligibleToMigrate++;
      console.log(`- [ELIGIBLE] ID: ${record.id} (${record.fileName}) -> Host: ${OLD_CLOUD_NAME}`);

      if (isDryRun) {
        mappingAudit.push({
          id: record.id,
          issueId: record.issueId,
          fileName: record.fileName,
          sourceUrl: url,
          action: "WOULD_MIGRATE",
          targetCloud: NEW_CLOUD_NAME || "[NEW_ACCOUNT]",
          targetFolder: TARGET_FOLDER,
        });
        continue;
      }

      // Execute migration for this asset
      try {
        console.log(`  Uploading to ${NEW_CLOUD_NAME}/${TARGET_FOLDER}...`);
        const uploadResult = await targetCloudinary.uploader.upload(url, {
          folder: TARGET_FOLDER,
          resource_type: "auto",
        });

        const newUrl = uploadResult.secure_url || uploadResult.url;
        console.log(`  Verifying accessibility of target asset...`);
        const isAccessible = await verifyUrlAccessible(newUrl);

        if (!isAccessible) {
          throw new Error(`Target URL returned non-200 status check`);
        }

        console.log(`  Updating PostgreSQL record ID: ${record.id}...`);
        await prisma.issueAttachment.update({
          where: { id: record.id },
          data: { fileUrl: newUrl },
        });

        summary.successfullyMigrated++;
        mappingAudit.push({
          id: record.id,
          issueId: record.issueId,
          fileName: record.fileName,
          oldUrl: url,
          newUrl,
          migratedAt: new Date().toISOString(),
          status: "SUCCESS",
        });
      } catch (err) {
        summary.failed++;
        console.error(`  FAILED to migrate record ${record.id}: ${err.message}`);
        mappingAudit.push({
          id: record.id,
          issueId: record.issueId,
          fileName: record.fileName,
          oldUrl: url,
          error: err.message,
          status: "FAILED",
        });
      }
    } else {
      summary.nonCloudinary++;
      console.log(`- [EXTERNAL/OTHER] ID: ${record.id} (${record.fileName}) -> Skipped`);
    }
  }

  // Save audit log
  const logDir = path.join(process.cwd(), "logs");
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
  const logPath = path.join(logDir, `cloudinary_migration_${Date.now()}.json`);
  fs.writeFileSync(logPath, JSON.stringify({ summary, mappingAudit }, null, 2), "utf8");

  console.log("\n============================================================");
  console.log(" Migration Summary");
  console.log("============================================================");
  console.log(` Total Records Scanned  : ${summary.total}`);
  console.log(` Already on New Account : ${summary.alreadyMigrated}`);
  console.log(` Eligible for Migration : ${summary.eligibleToMigrate}`);
  console.log(` External / Non-Cloud   : ${summary.nonCloudinary}`);
  if (!isDryRun) {
    console.log(` Successfully Migrated : ${summary.successfullyMigrated}`);
    console.log(` Failed Migrations     : ${summary.failed}`);
  }
  console.log(` Audit Log Saved To    : ${logPath}`);
  console.log("============================================================\n");
}

runMigration()
  .catch((err) => {
    console.error("Migration error:", err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
