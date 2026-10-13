/**
 * @file rename_etcr04_to_cbcr06.js
 * @description One-shot migration: renames Space code=ETCR-04 from "ETCR-04" → "CBCR-06".
 *
 * Run ONCE against the live database:
 *   node prisma/rename_etcr04_to_cbcr06.js
 *
 * This is safe to run on production. It ONLY updates the `name` field of that
 * specific Space record; all existing Issue records referencing that spaceId
 * are unaffected because they reference the Space by its UUID primary key.
 */

import "dotenv/config";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const space = await prisma.space.findUnique({ where: { code: "ETCR-04" } });

  if (!space) {
    console.log("[MIGRATION] Space with code ETCR-04 not found. Nothing to rename.");
    return;
  }

  if (space.name === "CBCR-06") {
    console.log("[MIGRATION] Space already named CBCR-06. No change needed.");
    return;
  }

  const updated = await prisma.space.update({
    where: { code: "ETCR-04" },
    data: { name: "CBCR-06" },
  });

  console.log(`[MIGRATION] Renamed Space id=${updated.id} from "${space.name}" to "${updated.name}"`);
}

main()
  .catch((e) => {
    console.error("[MIGRATION ERROR]", e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
