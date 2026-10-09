# InfraCare Backend API Documentation

> **System**: InfraCare — Smart Campus Infrastructure Management  
> **Base URL**: `/api/v1`  
> **Response Format**: `ApiResponse` (`{ success: true, message: string, data: any }`)

---

## 📱 Mobile APIs (Used directly by Flutter Mobile App)

### 1. Dashboard Endpoints
- `GET /api/v1/dashboard/summary`
  - Returns overview counts (`openIssues`, `inProgress`, `resolved`, `critical`).
- `GET /api/v1/dashboard/issues`
  - Returns issue breakdown by status & priority maps.
- `GET /api/v1/dashboard/recent-issues`
  - Returns top 5 latest reported issues with building and space location info.
- `GET /api/v1/dashboard/recent-work-orders`
  - Returns top 5 latest work orders.

### 2. Issue Management Flow
- `POST /api/v1/issues`
  - Creates a new infrastructure issue report.
  - Body: `{ title, description, priority, spaceId, assetId? }`
- `GET /api/v1/issues`
  - Lists issues reported by users with optional status (`OPEN`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`) and priority filters.
- `GET /api/v1/issues/:id`
  - Retrieves detailed issue status, location hierarchy, uploaded attachments, and resolution timeline.

---

## 🔍 Lookup APIs (Dropdown Selections for Reporting Flow)

These master-data endpoints power the cascading dropdown selectors on **Step 1** of the mobile Issue Reporting Stepper UI:

1. `GET /api/v1/campus` — List all campus nodes.
2. `GET /api/v1/buildings` — List buildings within a campus node.
3. `GET /api/v1/floors?buildingId=:id` — List floors within a selected building.
4. `GET /api/v1/spaces?floorId=:id` — List spaces/rooms within a selected floor.
5. `GET /api/v1/assets?spaceId=:id` — List optional assets within a selected space (unlocked only after Space selection).
6. `GET /api/v1/maintenance-departments` — List maintenance departments.

---

## 🛠️ Admin APIs (Preserved for Web Portal & Maintenance Backoffice)

The following CRUD endpoints remain fully operational and tested for administrative maintenance and master-data configuration:

### Buildings & Infrastructure Master Data
- `POST /api/v1/buildings` — Create building
- `PUT /api/v1/buildings/:id` — Update building
- `DELETE /api/v1/buildings/:id` — Soft-delete building
- `POST /api/v1/floors` — Create floor
- `PUT /api/v1/floors/:id` — Update floor
- `DELETE /api/v1/floors/:id` — Soft-delete floor
- `POST /api/v1/spaces` — Create space
- `PUT /api/v1/spaces/:id` — Update space
- `DELETE /api/v1/spaces/:id` — Soft-delete space
- `POST /api/v1/assets` — Create asset
- `PUT /api/v1/assets/:id` — Update asset
- `DELETE /api/v1/assets/:id` — Soft-delete asset

### Work Order Management
- `POST /api/v1/work-orders` — Dispatch work order
- `GET /api/v1/work-orders` — List work orders
- `GET /api/v1/work-orders/:id` — Work order details
- `PUT /api/v1/work-orders/:id` — Update work order status
- `DELETE /api/v1/work-orders/:id` — Cancel work order

---

## 🔄 Issue Reporting Flow Diagram

```
[ Mobile App ]
     │
     ├─ 1. Fetch Lookup Dropdowns (GET /buildings ➔ GET /floors ➔ GET /spaces ➔ GET /assets)
     │
     ├─ 2. Submit Issue (POST /issues)
     │
     ├─ 3. View Status & Updates (GET /issues & GET /issues/:id)
     │
     └─ 4. Dashboard Stats (GET /dashboard/summary & GET /dashboard/recent-issues)
```
