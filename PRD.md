# Product Requirements Document (PRD)
## Smart Complaint Management System (SCMS)

---

## 1. Executive Summary & Vision

The **Smart Complaint Management System (SCMS)** is an enterprise-grade citizen grievance and civic infrastructure management platform. It allows citizens to submit, track, and reopen complaints regarding public utilities (e.g., roads, electricity, water, sanitation). 

The platform leverages **Artificial Intelligence (Gemini 2.0 Flash)** to automatically classify complaint categories, assess severity, assign priority, and suggest target municipal departments. By automating routing, streamlining notification delivery, and providing department-specific dashboards, SCMS reduces manual triage latency, enhances public accountability, and optimizes local government workloads.

---

## 2. Problem Statement & Goals

### 2.1 Problem Statement
Traditional municipal grievance portals suffer from:
- **Manual Triage Bottlenecks:** Staff spend hours routing tickets to appropriate departments, leading to delayed resolutions.
- **Lack of Transparency:** Citizens have minimal visibility into who is working on their complaints or when they will be resolved.
- **Fragmented Notification Delivery:** Notification failures (e.g., mail server timeouts) result in lost updates without a systematic retry mechanism.
- **Inadequate Workload Visibility:** Department heads lack visual analytics to assess employee workload and resolution efficiencies.

### 2.2 Project Goals
- **Automated Grievance Routing:** Zero-touch assignment of complaints using AI-powered classification.
- **Audit-Trail Transparency:** Clear, chronological timeline tracking of every action taken on a complaint.
- **Reliable Communication:** Bulletproof notification engine that persists messages and retries failures automatically.
- **Intuitive Management:** Tailored portals for Citizens (Users), Field Officers (Department Members), and Admins.
- **Actionable Analytics:** Interactive reports and dashboards with export capabilities (Excel/PDF) for administrative audits.

---

## 3. User Roles & Persona Matrix

| Role | Access & Scope | Key Actions & Workflows |
| :--- | :--- | :--- |
| **Citizen (user)** | Restricted to self-created complaints. | <ul><li>Register & verify email</li><li>Submit complaint with title, description, and images</li><li>View personal complaint list & real-time timeline</li><li>Add notes / communication</li><li>Mark complaint as closed or request re-opening</li></ul> |
| **Department Member** | Restricted to complaints assigned to their designated department. | <ul><li>Access member dashboard with workload metrics</li><li>Assign complaint to self or delegate to team members</li><li>Log resolution notes & upload resolution proof files</li><li>Track pending, in-progress, and resolved items</li></ul> |
| **Administrator (admin)** | Global workspace access. | <ul><li>Oversee all complaints system-wide</li><li>Create and toggle departments</li><li>Register department members & adjust roles</li><li>Force-override department routing & assignees</li><li>Access high-level analytics & export CSV/PDF reports</li></ul> |

---

## 4. System Architecture & Tech Stack

```
[ Citizen / Member / Admin Web Client (React 19 + Tailwind CSS 4) ]
                             │
                             ▼  (HTTP REST API / JSON)
               [ Express.js Server Node.js (ESM) ]
                 ├── AI Service ────▶ [ Gemini 2.0 API ]
                 ├── Storage ───────▶ [ Cloudinary API ]
                 ├── Notifications ─▶ [ SMTP / Resend / SES / SendGrid ]
                 └── Database ──────▶ [ MongoDB / Mongoose ]
```

### 4.1 Frontend Stack
- **Library/Framework:** React 19 initialized via Vite
- **Styling:** Tailwind CSS v4 for fluid, modern dark-mode enabled design systems
- **Routing:** React Router Dom v7 with protected route middleware wrappers
- **State Management:** React Context API (`AuthContext`) with persistent LocalStorage tokens
- **Data Visualization:** Recharts for interactive dashboard graphs
- **Utility Libraries:** 
  - `axios` for client-side API requests
  - `lucide-react` for iconography
  - `xlsx`, `jspdf`, `html-to-image` for generating and downloading reports

### 4.2 Backend Stack
- **Platform:** Node.js (ES Modules configuration)
- **Framework:** Express.js v5 (Next-gen Express API)
- **Database ORM:** Mongoose v9 for MongoDB modeling
- **AI SDK:** `@google/genai` (Official modern Google Gemini SDK)
- **Logger:** Winston for structured JSON logs
- **Scheduling:** `node-cron` for scheduled analytics & notification retries
- **Testing:** Jest + MongoDB Memory Server for isolated, reproducible backend integration testing

---

## 5. Database Schema & Models

The MongoDB database contains 5 core schemas to manage users, roles, departments, complaints, and system logs.

### 5.1 User Model
Stores account credentials, system roles, email verification states, and security tokens.
- **fullName**: `String`
- **email**: `String` (Unique, lowercase)
- **password**: `String` (Bcrypt hashed)
- **role**: `admin` | `department_member` | `user`
- **phoneNumber**: `String`
- **employeeId**: `String` (Unique, sparse index)
- **isActive**: `Boolean` (Default `true`)
- **emailVerified**: `Boolean` (Default `false`)
- **lastLoginAt**: `Date`

### 5.2 Department Model
Defines the municipal branches that process complaints.
- **name**: `String` (Unique)
- **code**: `String` (Unique, uppercase, e.g., `"ROAD"`, `"WATER"`, `"ELECTRIC"`, `"GARBAGE"`, `"SAFETY"`, `"HEALTH"`, `"IT"`)
- **description**: `String`
- **head**: `String` (Head name)
- **email**: `String`
- **phone**: `String`
- **isActive**: `Boolean`

### 5.3 Department Member Model
Junction model linking Users (staff) to their assigned Departments, designating operational ranks.
- **department**: Reference to `Department`
- **user**: Reference to `User`
- **deptRole**: `HEAD` | `ADMIN` | `SUPERVISOR` | `FIELD_OFFICER`
- **isPrimary**: `Boolean`
- **isActive**: `Boolean`

### 5.4 Complaint Model
Tracks the lifecycle, ownership, media attachments, timeline events, and notes of a grievance.
- **title**: `String`
- **description**: `String`
- **category**: `ROAD_DAMAGE` | `WATER_LEAKAGE` | `GARBAGE_COLLECTION` | `STREET_LIGHT` | `DRAINAGE` | `PUBLIC_SAFETY` | `HEALTH_SANITATION` | `IT_WEBSITE` | `OTHER`
- **location**: `String`
- **priority**: `Low` | `Medium` | `High` (Default `Medium`)
- **status**: `Pending` | `In Progress` | `Resolved` | `Closed` (Default `Pending`)
- **images**: Array of Cloudinary metadata objects (url, secureUrl, publicId, etc.)
- **timeline**: Array of events tracking history (type, title, description, performedBy, performedByRole, metadata, createdAt)
- **aiMetadata**: Prediction json output, confidence score, model name, generation timestamp
- **department**: Reference to `Department`
- **assignedMember**: Reference to `DepartmentMember`
- **notes**: Array of messages (author, text, createdAt)
- **resolutionProof**: Array of verification documents uploaded upon resolution

### 5.5 Notification Model
Tracks the history and delivery status of all dispatch requests (emails, sms, pushes).
- **recipient**: Reference to `User`
- **type**: Enum of event types (e.g. `COMPLAINT_SUBMITTED`, `COMPLAINT_RESOLVED`, `PASSWORD_RESET_SUCCESS`)
- **channel**: `email` | `sms` | `push`
- **status**: `pending` | `sent` | `failed` | `retried`
- **subject**: `String`
- **body**: `String` (Rendered HTML template payload)
- **provider**: `smtp` | `resend` | `sendgrid` | `ses`
- **retryCount**: `Number` (Max `3` retries)
- **lastError**: `String` (Stores error messages for engineering audit)

---

## 6. Key Workflows & Functional Requirements

### 6.1 Grievance Submission Flow
1. **User Input:** The citizen provides a Title, Description, Location, and uploads optional photos.
2. **AI Categorization:** 
   - Before submission, the frontend calls `/api/ai/analyze-complaint` using Gemini.
   - Gemini evaluates the text and returns predicted fields: `category`, `priority`, `severity`, `summary`, and `estimatedResolution`.
3. **Automated Department Suggestion:**
   - The backend maps the category (e.g. `ROAD_DAMAGE` to `ROAD`) and searches for an active `Department` document with that code.
   - If found, the complaint is automatically linked to the department.
4. **Image Upload with Rollback:**
   - Images are processed using `multer` and streamed directly to Cloudinary.
   - If any image fails to upload, a rollback function triggers, deleting any previously uploaded assets in that batch and cancelling MongoDB creation to maintain state consistency.
5. **Initial Timeline Entry:** A `COMPLAINT_CREATED` event is saved.
6. **Dispatches:** Notifications are queued to tell the user their complaint is pending and alert admins.

### 6.2 Complaint Assignment Flow
- **Automatic Routing:** Newly created complaints route directly to the designated department queue.
- **Admin & Member Triage:**
   - Admins can assign any department.
   - Department Supervisors/Members can self-assign or assign to other members within their department.
- **Audit Logs:** A timeline entry (`DEPARTMENT_ASSIGNED` or `MEMBER_ASSIGNED`) records who initiated the transfer.

### 6.3 Resolution Proof Flow
- When a department member resolves a complaint, they are required to upload files (such as "before/after" photos or work reports).
- The complaint's status is set to `Resolved` and a `COMPLAINT_RESOLVED` event is written.
- The user is notified of the resolution. If the user does not reopen the complaint, it will eventually close. Alternatively, the user can mark the issue as `Closed` or `Reopened` manually.

### 6.4 Failed Notification Retry Engine
```
                  [ Notification Triggered ]
                             │
                             ▼
                 ( Persist to DB as "pending" )
                             │
                             ▼
                    [ Dispatch Email ]
                             │
            ┌────────────────┴────────────────┐
         Success                           Failure
            │                                 │
            ▼                                 ▼
    ( Status: "sent" )               ( Status: "failed" )
    ( DB TTL set: 90d )              ( Record Error, Inc RetryCount )
                                              │
                                              ▼
                                    [ Cron Retry Job ]
                                ( Runs every 5m: Max 3 Retries )
```
1. **Pre-dispatch Logging:** The notification is saved to the database as `pending` before sending.
2. **Send Phase:** The email is sent via the configured provider (e.g. SMTP). If successful, status changes to `sent`.
3. **Fail Phase:** If sending fails, the status becomes `failed`, the error trace is saved, and `retryCount` is incremented.
4. **Background Re-try Queue:** A cron job running every 5 minutes queries failed notifications with a `retryCount < 3` and retries them.
5. **Garbage Collection (TTL):** A MongoDB TTL index is placed on `sentAt` for sent notifications, automatically deleting them after 90 days.

---

## 7. Security & Non-Functional Requirements

- **CORS Protection:** Configured with a white-list of trusted origins (e.g. the React client IP/domain).
- **Security Headers:** Implemented via Helmet.js to prevent Cross-Site Scripting (XSS), clickjacking, and mime-sniffing.
- **Rate Limiting:** Employs `express-rate-limit` to prevent denial-of-service (DoS) and brute force attacks on auth and AI endpoints.
- **Authentication:** Uses secure HTTP-only cookies containing JSON Web Tokens (JWT).
- **Validation:** Strict verification checking on email addresses before allowing ticket submissions. Password reset links are generated using SHA-256 tokens with a 1-hour expiration.

---

## 8. Deployment & Environment Settings

### 8.1 Docker Compose Configuration
SCMS includes local Docker support. The `docker-compose.yml` mounts:
- `backend`: Node service bound to port `5000`
- `frontend`: Vite React service bound to port `5173`
- `mongodb`: Dev database container bound to port `27017`

### 8.2 Crucial Environment Variables
#### Backend (`.env`)
- `PORT` (e.g., `5000`)
- `MONGO_URI` (MongoDB connection string)
- `JWT_SECRET` (Auth token signatures)
- `GEMINI_API_KEY` (Enables automated classification via Gemini 2.0 Flash)
- `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_API_KEY` / `CLOUDINARY_API_SECRET`
- `SMTP_HOST` / `SMTP_PORT` / `SMTP_USER` / `SMTP_PASS` (Mail server login)
- `EMAIL_FROM` (Outgoing mail sender name)

#### Frontend (`.env`)
- `VITE_API_URL` (Base backend path, e.g. `http://localhost:5000/api`)
