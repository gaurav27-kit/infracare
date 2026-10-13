# InfraCare Backend Service

> **InfraCare** — Smart Campus Infrastructure Management  
> Node.js / Express / Prisma ORM / PostgreSQL Service API

---

## 🛠️ Tech Stack & Layers

- **Framework**: Express.js (ES Modules)
- **Database ORM**: Prisma ORM with PostgreSQL
- **Validation**: Zod
- **Logger**: Winston (Logging state mutations: POST, PUT, PATCH, DELETE)
- **Testing**: Jest & Supertest

---

## 🚀 Getting Started

### Installation & Test Run
```bash
# Install dependencies
npm install

# Run test suite
npm test

# Start development server
npm run dev
```

---

## 📂 Architecture Structure

```
backend/
├── src/
│   ├── config/          # Prisma & DB configurations
│   ├── controllers/     # Route request handlers
│   ├── middleware/      # Logger, error handler, rate limiter, validation
│   ├── repositories/    # Data access layer (Prisma queries)
│   ├── routes/v1/       # REST API endpoints
│   ├── seeders/         # Seed scripts
│   ├── services/        # Business logic layer
│   ├── types/           # Enums & constants
│   ├── utils/           # ApiResponse, ApiError, logger, asyncHandler
│   └── validators/      # Zod schemas
└── tests/               # Jest test suites
```
