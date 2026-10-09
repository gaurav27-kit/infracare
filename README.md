# InfraCare — Smart Campus Infrastructure Management

> **Final Year Engineering Project (2026)**  
> **Tagline**: Smart Campus Infrastructure Management  
> **Tech Stack**: Node.js, Express, Prisma ORM, PostgreSQL, Winston, Jest

---

## 📌 Project Overview

**InfraCare** is an enterprise-grade campus infrastructure management platform designed for students, faculty, and campus maintenance departments to report, track, and resolve physical infrastructure issues across university campuses.

The backend provides high-performance RESTful APIs supporting:
- **Mobile Application Views**: Dashboard, Report Issue, My Issues, Issue Details, Settings.
- **Lookup Master-Data APIs**: Cascading data selection (Building $\rightarrow$ Floor $\rightarrow$ Space $\rightarrow$ Asset).
- **Admin APIs**: Complete CRUD operations preserved for future campus administration portals.

---

## 🛠️ Architecture

```
Routes (Express v1 Router)
  ↓
Controllers (Async Handlers & Standardized ApiResponse)
  ↓
Services (Business Logic & Validation)
  ↓
Repositories (Prisma ORM Data Access Layer)
  ↓
PostgreSQL Database
```

---

## 📡 API Endpoint Categorization

### 1. Mobile APIs (Used directly by Flutter app)
- `GET /api/v1/dashboard/summary` — Campus overview metrics & counts
- `GET /api/v1/dashboard/issues` — Issue statistics grouped by status and priority
- `GET /api/v1/dashboard/recent-issues` — Top 5 recent active issues
- `POST /api/v1/issues` — Submit new infrastructure report
- `GET /api/v1/issues` — View reported issues list with search & status filters
- `GET /api/v1/issues/:id` — View detailed issue status & timeline

### 2. Lookup APIs (Dropdown selections for Issue Reporting)
- `GET /api/v1/campus` — Campus list
- `GET /api/v1/buildings` — Buildings lookup
- `GET /api/v1/floors` — Floors lookup (filtered by building)
- `GET /api/v1/spaces` — Spaces lookup (filtered by floor)
- `GET /api/v1/assets` — Assets lookup (filtered by space)
- `GET /api/v1/maintenance-departments` — Maintenance department lookup

### 3. Admin APIs (Preserved for future Web Admin Portal)
- `POST/PUT/DELETE /api/v1/buildings` — Building management
- `POST/PUT/DELETE /api/v1/floors` — Floor management
- `POST/PUT/DELETE /api/v1/spaces` — Space management
- `POST/PUT/DELETE /api/v1/assets` — Asset management
- `POST/PUT/DELETE /api/v1/work-orders` — Work order dispatch & management

---

## 🧪 Testing

Run the unit and integration test suite:
```bash
npm --prefix backend test
```

All 10 test suites and 168+ tests pass with zero errors.

---

## 📄 License
InfraCare System — Third Year Engineering Project.
