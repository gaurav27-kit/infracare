# InfraCare Backend — Integration & Handoff Guide

> **Module Role**: Campus Physical Infrastructure Management & Issue Tracking Microservice  
> **Target Frontend**: Centralized Flutter Mobile App  
> **Auth Model**: Centralized Single Auth via API Gateway / Header Pass-through  

---

## 1. Architecture & Centralized Auth Flow

This backend module is designed to plug directly into your centralized campus platform. It does **not** manage its own independent login/user table, avoiding split authentication states across modules.

### How Centralized Auth Works:

```
[ Centralized Flutter App ]
           │
           │  1. Attaches User Token or Header
           │     Headers:
           │       x-user-id: "usr_student_123"
           │       Authorization: "Bearer <central_jwt_token>"
           ▼
[ InfraCare Backend API ]
           │
           │  2. `extractUserContext` middleware extracts User ID & Role
           │  3. Issues and audit logs are automatically tagged with this User ID
           ▼
[ PostgreSQL Database (Prisma) ]
```

### Passing User Identity:
Your Flutter frontend (or API Gateway) can provide the logged-in user in **any** of the following ways:

1. **Custom Header (Recommended)**:
   ```http
   x-user-id: <currentUser.id>
   x-user-role: student | admin
   ```
2. **Bearer JWT Token**:
   ```http
   Authorization: Bearer <your_central_jwt_token>
   ```
   *The backend will automatically extract `sub`, `id`, or `userId` from the JWT claims.*
3. **Explicit Payload Body**:
   ```json
   {
     "reporterExternalUserId": "<currentUser.id>"
   }
   ```

---

## 2. API Endpoints Reference

### 📊 Dashboard & Analytics (Mobile Home Screen)

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/dashboard/summary` | Campus issue stats: `openIssues`, `inProgress`, `resolved`, `critical` |
| `GET` | `/api/v1/dashboard/issues` | Grouped issue counts by status and priority |
| `GET` | `/api/v1/dashboard/recent-issues` | Top 5 recent active issues with building & space info |
| `GET` | `/api/v1/dashboard/recent-work-orders` | Top 5 recent work orders |

---

### 🏛️ Cascading Master Data (Issue Creation Dropdowns)

Used for the step-by-step issue creation form:

1. **Campuses**: `GET /api/v1/campus`
2. **Buildings**: `GET /api/v1/buildings`
3. **Floors** (filter by building): `GET /api/v1/floors?buildingId={id}`
4. **Spaces / Rooms** (filter by floor): `GET /api/v1/spaces?floorId={id}`
5. **Assets** (optional, filter by space): `GET /api/v1/assets?spaceId={id}`
6. **Departments**: `GET /api/v1/maintenance-departments`

---

### 📝 Issue Reporting & Tracking

#### 1. Report New Issue
- **Method**: `POST /api/v1/issues`
- **Headers**:
  ```http
  Content-Type: application/json
  x-user-id: usr_12345
  ```
- **Body**:
  ```json
  {
    "spaceId": "33333333-3333-3333-8333-333333333333",
    "assetId": "55555555-5555-5555-8555-555555555555", 
    "customAssetName": null,
    "title": "Air Conditioner not cooling",
    "description": "The AC in Lab 101 stopped cooling since this morning.",
    "priority": "HIGH"
  }
  ```
  *(Priority values: `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`)*

#### 2. Get Issues List (My Issues / Filtered Issues)
- **Method**: `GET /api/v1/issues`
- **Query Parameters**:
  - `page`: default `1`
  - `limit`: default `20`
  - `status`: `OPEN` | `ASSIGNED` | `IN_PROGRESS` | `RESOLVED` | `CLOSED`
  - `priority`: `LOW` | `MEDIUM` | `HIGH` | `CRITICAL`
  - `search`: keyword string search in title/description

#### 3. Get Single Issue Detail
- **Method**: `GET /api/v1/issues/:id`
- **Response**: Complete issue record with attached space, building, floor, asset details, attachments, and timeline.

#### 4. Upload Attachment Image
- **Method**: `POST /api/v1/issues/:issueId/attachments`
- **Content-Type**: `multipart/form-data`
- **Form field**: `file` (image file)

---

## 3. Standard Response Format

All responses follow a consistent envelope:

```json
{
  "success": true,
  "message": "Issues retrieved successfully",
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 4,
    "totalPages": 1
  }
}
```

Error responses:
```json
{
  "success": false,
  "message": "Space with ID xxx not found",
  "errors": []
}
```

---

## 4. Cloud Deployment (Render / Railway / PaaS)

### Option A: Deploy to Render / Railway (Docker)
1. Point your service to the repository.
2. Select **Docker** environment (context: `./backend`, Dockerfile: `Dockerfile`).
3. Set the following Environment Variables:
   - `PORT`: `5000`
   - `DATABASE_URL`: `postgresql://user:pass@host:5432/dbname?sslmode=require`
   - `CLOUDINARY_CLOUD_NAME`: `<your_cloud_name>`
   - `CLOUDINARY_API_KEY`: `<your_api_key>`
   - `CLOUDINARY_API_SECRET`: `<your_api_secret>`
   - `ALLOWED_ORIGINS`: `*`

### Option B: Deploy to Render / Railway (Native Node.js)
1. **Root Directory**: `backend`
2. **Build Command**: `npm ci && npm run migrate:deploy`
3. **Start Command**: `npm start`
4. Set the same Environment Variables as above.

### Initial Database Seeding
To populate default campus buildings, floors, spaces, and asset categories on your new database:
```bash
npm run seed
```
