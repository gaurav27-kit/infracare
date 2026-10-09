# Master Data Foundation Documentation

## Overview
The **Master Data Foundation** establishes the single source of truth for all shared enums, system constants, and validation constraints across the Smart Campus Management System. Every backend module (Campus, Building, Floor, Space, Asset, Issue, WorkOrder, Maintenance) imports from this central location (`src/types/index.js`).

---

## 1. Shared Enums (`src/types/enums.js`)

| Enum Name | Enum Values | Description & Dependent Modules |
| :--- | :--- | :--- |
| **`SpaceType`** | `CLASSROOM`, `LABORATORY`, `OFFICE`, `LIBRARY`, `SEMINAR_HALL`, `WORKSHOP`, `CORRIDOR`, `STAIRCASE`, `WASHROOM`, `CAFETERIA`, `HOSTEL_ROOM`, `STORE_ROOM`, `SERVER_ROOM`, `ELECTRICAL_ROOM`, `OTHER` | Classifies space usage across campus. Used by **Space Module**, **Asset Module**, and **Issue Module**. |
| **`AssetStatus`** | `OPERATIONAL`, `FAULTY`, `UNDER_MAINTENANCE`, `DECOMMISSIONED` | Operational status of physical equipment. Used by **Asset Module**, **Issue Module**, and **WorkOrder Module**. |
| **`IssuePriority`** | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` | Severity ranking of reported campus issues. Used by **Issue Module** and **WorkOrder Module**. |
| **`IssueStatus`** | `OPEN`, `ASSIGNED`, `IN_PROGRESS`, `RESOLVED`, `CLOSED` | Lifecycle status of an issue. Used by **Issue Module** and **WorkOrder Module**. |
| **`WorkOrderPriority`** | `LOW`, `MEDIUM`, `HIGH`, `EMERGENCY` | Priority assigned to maintenance work tasks. Used by **WorkOrder Module**. |
| **`WorkOrderStatus`** | `SCHEDULED`, `IN_PROGRESS`, `ON_HOLD`, `COMPLETED`, `CANCELLED` | Execution state of work orders. Used by **WorkOrder Module** and **Maintenance History**. |
| **`MaintenanceType`** | `PREVENTIVE`, `CORRECTIVE`, `EMERGENCY` | Maintenance activity type. Used by **WorkOrder Module** and **Asset Maintenance History**. |

---

## 2. System Constants (`src/types/constants.js`)

| Constant Category | Key Name | Value | Used By |
| :--- | :--- | :--- | :--- |
| **System Info** | `APP_NAME` | `"Smart Campus Management System"` | Health endpoint, logging, emails |
| **System Info** | `API_VERSION` | `"v1"` | Route mounting & response payloads |
| **System Info** | `DEFAULT_TIMEZONE` | `"UTC"` | Date parsing & scheduled jobs |
| **System Info** | `DEFAULT_DATE_FORMAT` | `"YYYY-MM-DDTHH:mm:ss.SSSZ"` | Formatting audit timestamps |
| **Uploads** | `MAX_IMAGE_UPLOAD_SIZE` | `10485760` (10 MB) | Multer & upload middleware |
| **Uploads** | `ALLOWED_IMAGE_EXTENSIONS` | `[".jpg", ".jpeg", ".png", ".webp"]` | Upload validation |
| **Uploads** | `ALLOWED_IMAGE_MIME_TYPES` | `["image/jpeg", "image/png", "image/webp"]` | Upload validation |
| **Pagination** | `DEFAULT_PAGE` | `1` | Pagination repositories & controllers |
| **Pagination** | `DEFAULT_PAGE_SIZE` | `10` | Pagination repositories & controllers |
| **Pagination** | `MAX_PAGE_SIZE` | `100` | Pagination repositories & controllers |
| **Hardware** | `QR_CODE_PREFIX` | `"QR-"` | Asset QR Code generators & scanners |

---

## 3. Validation Bounds (`src/types/validation.constants.js`)

Provides schema validation bounds for Zod request validators across all modules:

- **Campus**: Name (2-150 chars), Code (2-20 chars), Phone (max 50 chars), Email (max 255 chars)
- **Building**: Name (2-150 chars), Code (2-30 chars)
- **Floor**: Name (1-100 chars), Level (-5 to 150)
- **Space**: Name (2-150 chars), Capacity (0 to 5000)
- **Asset Category**: Name (2-100 chars)
- **Asset**: Name (2-150 chars), Serial Number (2-100 chars)
- **Issue**: Title (3-200 chars), Description (5-5000 chars)
- **WorkOrder**: Cost (0 to 1,000,000), Resolution Notes (max 5000 chars)

---

## 4. Module Dependency Matrix

```
                          ┌───────────────────────────┐
                          │   src/types/index.js      │
                          └─────────────┬─────────────┘
                                        │
        ┌──────────────┬────────────────┼──────────────┬──────────────┐
        ▼              ▼                ▼              ▼              ▼
  [Campus Module] [Building]         [Space]        [Asset]    [Issue / WorkOrder]
  - Campus        - BuildingCode     - SpaceType    - Status   - Status / Priority
  - Limits        - Limits           - Capacity     - Limits   - Limits
```
