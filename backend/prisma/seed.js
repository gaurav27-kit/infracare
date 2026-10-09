/**
 * @file seed.js
 * @description Standard Prisma Database Seeding Script for InfraCare - AIML Department.
 * Run via: `npx prisma db seed` or `node prisma/seed.js`.
 */

import "dotenv/config";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// ─── 1. Seed Campus ───────────────────────────────────────────────────────────
export async function seedCampus() {
  let campus = await prisma.campus.findFirst({
    where: { deletedAt: null },
  });

  const campusData = {
    name: "AIML Department Campus",
    code: "AIML-CAMPUS",
    description: "InfraCare — AIML Department Infrastructure Issue Management System",
    address: "Department of Artificial Intelligence & Machine Learning",
    phone: "+1-800-555-0199",
    email: "aiml-facilities@infracare.edu",
    website: "https://aiml.infracare.edu",
    logoUrl: "https://aiml.infracare.edu/assets/logo.png",
  };

  if (!campus) {
    campus = await prisma.campus.create({ data: campusData });
    console.log(`[SEED] ✅ Created single Campus: ${campus.name} (${campus.code})`);
  } else {
    campus = await prisma.campus.update({
      where: { id: campus.id },
      data: campusData,
    });
    console.log(`[SEED] ℹ️ Updated single Campus: ${campus.name} (${campus.code})`);
  }

  return campus;
}

// ─── 2. Seed Buildings ────────────────────────────────────────────────────────
export async function seedBuildings(campusId) {
  // Only AIML Building for AIML Department scope
  const buildingDefinitions = [
    { name: "AIML Building", code: "AIML-BLD" },
  ];

  const buildingsMap = {};
  for (const b of buildingDefinitions) {
    const building = await prisma.building.upsert({
      where: { code: b.code },
      update: { name: b.name, campusId, deletedAt: null },
      create: {
        campusId,
        name: b.name,
        code: b.code,
      },
    });
    buildingsMap[b.code] = building;
  }
  console.log(`[SEED] ✅ Seeded ${Object.keys(buildingsMap).length} Buildings`);
  return buildingsMap;
}

// ─── 3. Seed Floors ───────────────────────────────────────────────────────────
export async function seedFloors(buildingsMap) {
  const aimlBuilding = buildingsMap["AIML-BLD"];
  if (!aimlBuilding) {
    throw new Error("AIML Building not found during floor seeding");
  }

  const floorDefinitions = [
    { level: 1, name: "1st Floor" },
    { level: 2, name: "2nd Floor" },
  ];

  const floorsMap = {};
  for (const f of floorDefinitions) {
    const floor = await prisma.floor.upsert({
      where: { buildingId_level: { buildingId: aimlBuilding.id, level: f.level } },
      update: { name: f.name, deletedAt: null },
      create: {
        buildingId: aimlBuilding.id,
        level: f.level,
        name: f.name,
      },
    });
    floorsMap[f.level.toString()] = floor;
  }
  console.log(`[SEED] ✅ Seeded ${Object.keys(floorsMap).length} Floors for AIML Building`);
  return floorsMap;
}

// ─── 4. Seed Spaces ───────────────────────────────────────────────────────────
export async function seedSpaces(floorsMap) {
  const floor1 = floorsMap["1"];
  const floor2 = floorsMap["2"];

  if (!floor1 || !floor2) {
    throw new Error("Floors missing during space seeding");
  }

  // Exact names specified:
  // 1st Floor: Apple Lab, CSAM Lab 02, CSAM Lab 03, UPS Room, CSAM CR-02, CSAM CR-03, CSAM CR-04, CSAM CR-05, CSAM CR-06, CSAM Lab 04, CSDS Lab 01, Washroom
  // 2nd Floor: CSAM CR-01, CSDS CR-01, ETCR-04, Washroom
  const spaceDefinitions = [
    // 1st Floor
    { floorId: floor1.id, name: "Apple Lab", code: "APPLE-LAB", type: "LABORATORY", capacity: 40, isAccessible: true },
    { floorId: floor1.id, name: "CSAM Lab 02", code: "CSAM-LAB-02", type: "LABORATORY", capacity: 40, isAccessible: true },
    { floorId: floor1.id, name: "CSAM Lab 03", code: "CSAM-LAB-03", type: "LABORATORY", capacity: 40, isAccessible: true },
    { floorId: floor1.id, name: "UPS Room", code: "UPS-ROOM-L1", type: "ELECTRICAL_ROOM", capacity: 4, isAccessible: false },
    { floorId: floor1.id, name: "CSAM CR-02", code: "CSAM-CR-02", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor1.id, name: "CSAM CR-03", code: "CSAM-CR-03", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor1.id, name: "CSAM CR-04", code: "CSAM-CR-04", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor1.id, name: "CSAM CR-05", code: "CSAM-CR-05", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor1.id, name: "CSAM CR-06", code: "CSAM-CR-06", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor1.id, name: "CSAM Lab 04", code: "CSAM-LAB-04", type: "LABORATORY", capacity: 40, isAccessible: true },
    { floorId: floor1.id, name: "CSDS Lab 01", code: "CSDS-LAB-01", type: "LABORATORY", capacity: 40, isAccessible: true },
    { floorId: floor1.id, name: "Washroom", code: "WASHROOM-L1", type: "WASHROOM", capacity: 10, isAccessible: true },

    // 2nd Floor
    { floorId: floor2.id, name: "CSAM CR-01", code: "CSAM-CR-01", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor2.id, name: "CSDS CR-01", code: "CSDS-CR-01", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor2.id, name: "ETCR-04", code: "ETCR-04", type: "CLASSROOM", capacity: 60, isAccessible: true },
    { floorId: floor2.id, name: "Washroom", code: "WASHROOM-L2", type: "WASHROOM", capacity: 10, isAccessible: true },
  ];

  const spacesMap = {};
  for (const s of spaceDefinitions) {
    const space = await prisma.space.upsert({
      where: { code: s.code },
      update: {
        floorId: s.floorId,
        name: s.name,
        type: s.type,
        capacity: s.capacity,
        isAccessible: s.isAccessible,
        deletedAt: null,
      },
      create: {
        floorId: s.floorId,
        name: s.name,
        code: s.code,
        type: s.type,
        capacity: s.capacity,
        isAccessible: s.isAccessible,
      },
    });
    spacesMap[s.code] = space;
  }
  console.log(`[SEED] ✅ Seeded ${Object.keys(spacesMap).length} Spaces in AIML Building`);
  return spacesMap;
}

// ─── 5. Seed Asset Categories ─────────────────────────────────────────────────
export async function seedAssetCategories() {
  const categoryDefinitions = [
    { name: "IT & Audio/Visual", description: "Projectors, smart displays, workstations, networking, and AV hardware." },
    { name: "HVAC & Climate Control", description: "Heating, ventilation, air conditioning units, and chillers." },
    { name: "Electrical & Power", description: "UPS units, switchboards, lighting fixtures, and power distribution." },
    { name: "Plumbing & Sanitation", description: "Water purifiers, washroom fixtures, and plumbing systems." },
    { name: "Safety & Fire Protection", description: "Fire extinguishers, smoke detectors, and emergency alarms." },
  ];

  const categoriesMap = {};
  for (const c of categoryDefinitions) {
    const cat = await prisma.assetCategory.upsert({
      where: { name: c.name },
      update: { description: c.description },
      create: {
        name: c.name,
        description: c.description,
      },
    });
    categoriesMap[c.name] = cat;
  }
  console.log(`[SEED] ✅ Seeded ${Object.keys(categoriesMap).length} Asset Categories`);
  return categoriesMap;
}

// ─── 6. Seed Assets ───────────────────────────────────────────────────────────
export async function seedAssets(spacesMap, categoriesMap) {
  const assetDefinitions = [
    {
      spaceCode: "APPLE-LAB",
      categoryName: "IT & Audio/Visual",
      name: "Apple iMac 27-inch Lab Workstation 01",
      code: "APL-MAC-01",
      serialNumber: "AIML-APL-001",
      qrCode: "QR-AIML-APL-001",
      status: "OPERATIONAL",
    },
    {
      spaceCode: "CSAM-LAB-02",
      categoryName: "IT & Audio/Visual",
      name: "High-Performance Workstation Pool A",
      code: "CSAM-WS-02",
      serialNumber: "AIML-CSAM-WS02",
      qrCode: "QR-AIML-CSAM-WS02",
      status: "OPERATIONAL",
    },
    {
      spaceCode: "UPS-ROOM-L1",
      categoryName: "Electrical & Power",
      name: "Central Online UPS 30kVA",
      code: "UPS-30KVA",
      serialNumber: "AIML-UPS-001",
      qrCode: "QR-AIML-UPS-001",
      status: "OPERATIONAL",
    },
    {
      spaceCode: "CSAM-CR-01",
      categoryName: "IT & Audio/Visual",
      name: "Classroom Smart Projector & Audio",
      code: "CR01-PROJ",
      serialNumber: "AIML-CR01-PROJ",
      qrCode: "QR-AIML-CR01-PROJ",
      status: "OPERATIONAL",
    },
  ];

  const assetsList = [];
  for (const a of assetDefinitions) {
    const space = spacesMap[a.spaceCode];
    const category = categoriesMap[a.categoryName];
    if (!space || !category) continue;

    const asset = await prisma.asset.upsert({
      where: { code: a.code },
      update: {
        spaceId: space.id,
        categoryId: category.id,
        status: a.status,
        name: a.name,
        serialNumber: a.serialNumber,
        qrCode: a.qrCode,
      },
      create: {
        spaceId: space.id,
        categoryId: category.id,
        name: a.name,
        code: a.code,
        serialNumber: a.serialNumber,
        qrCode: a.qrCode,
        status: a.status,
      },
    });
    assetsList.push(asset);
  }
  console.log(`[SEED] ✅ Seeded ${assetsList.length} Assets`);
  return assetsList;
}

// ─── 7. Seed Maintenance Departments ────────────────────────────────────────
export async function seedMaintenanceDepartments() {
  const deptDefinitions = [
    {
      name: "AIML Facility Management",
      code: "AIML-FAC",
      email: "aiml-facilities@infracare.edu",
      phone: "+1-800-555-0100",
      description: "Dedicated infrastructure support for AIML Department & Building.",
    },
    {
      name: "IT Support Services",
      code: "IT-SUPP",
      email: "itsupport@infracare.edu",
      phone: "+1-800-555-0122",
      description: "Handles lab workstations, servers, projectors, and networking.",
    },
    {
      name: "Electrical & Power Services",
      code: "ELEC",
      email: "electrical@infracare.edu",
      phone: "+1-800-555-0111",
      description: "Handles UPS systems, wiring, lighting, and power outlets.",
    },
  ];

  const deptsList = [];
  for (const d of deptDefinitions) {
    const dept = await prisma.maintenanceDepartment.upsert({
      where: { code: d.code },
      update: { name: d.name, email: d.email, phone: d.phone, description: d.description },
      create: {
        name: d.name,
        code: d.code,
        email: d.email,
        phone: d.phone,
        description: d.description,
      },
    });
    deptsList.push(dept);
  }
  console.log(`[SEED] ✅ Seeded ${deptsList.length} Maintenance Departments`);
  return deptsList;
}

// ─── 8. Seed Verification Step ───────────────────────────────────────────────
export async function verifySeedData() {
  const [campusCount, buildingCount, floorCount, spaceCount, categoryCount, assetCount, deptCount] = await Promise.all([
    prisma.campus.count({ where: { deletedAt: null } }),
    prisma.building.count({ where: { deletedAt: null } }),
    prisma.floor.count({ where: { deletedAt: null } }),
    prisma.space.count({ where: { deletedAt: null } }),
    prisma.assetCategory.count({ where: { deletedAt: null } }),
    prisma.asset.count({ where: { deletedAt: null } }),
    prisma.maintenanceDepartment.count({ where: { deletedAt: null } }),
  ]);

  console.log("\n==================================================");
  console.log("   INFRACARE - AIML DEPARTMENT SEED SUMMARY       ");
  console.log("==================================================");
  console.log(`  ✓ Campus Record               : ${campusCount} (Single Campus)`);
  console.log(`  ✓ Buildings                   : ${buildingCount} (AIML Building)`);
  console.log(`  ✓ Floors                      : ${floorCount} (1st Floor, 2nd Floor)`);
  console.log(`  ✓ Spaces / Rooms              : ${spaceCount} (12 on 1st Floor, 4 on 2nd Floor)`);
  console.log(`  ✓ Asset Categories            : ${categoryCount}`);
  console.log(`  ✓ Assets                      : ${assetCount}`);
  console.log(`  ✓ Maintenance Departments     : ${deptCount}`);
  console.log("==================================================\n");

  if (buildingCount !== 1) {
    throw new Error(`Seed Verification Failed: Expected exactly 1 Building (AIML Building), found ${buildingCount}`);
  }

  if (floorCount !== 2) {
    throw new Error(`Seed Verification Failed: Expected exactly 2 Floors, found ${floorCount}`);
  }

  if (spaceCount !== 16) {
    throw new Error(`Seed Verification Failed: Expected exactly 16 Spaces, found ${spaceCount}`);
  }

  return {
    campusCount,
    buildingCount,
    floorCount,
    spaceCount,
    categoryCount,
    assetCount,
    deptCount,
  };
}

// ─── Main Execution Handler ──────────────────────────────────────────────────
export async function main() {
  console.log("[SEED] Starting AIML Department database seeding...");
  const campus = await seedCampus();
  const buildingsMap = await seedBuildings(campus.id);
  const floorsMap = await seedFloors(buildingsMap);
  const spacesMap = await seedSpaces(floorsMap);
  const categoriesMap = await seedAssetCategories();
  await seedAssets(spacesMap, categoriesMap);
  await seedMaintenanceDepartments();
  await verifySeedData();
  console.log("[SEED] AIML Department database seeding completed successfully!");
}

if (process.argv[1]?.endsWith("seed.js")) {
  main()
    .catch((e) => {
      console.error("[SEED ERROR] Seeding failed:", e);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}
