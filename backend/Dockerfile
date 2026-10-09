# ─── InfraCare Backend — Production Dockerfile ──────────────────────────────
# Node.js 20 LTS (Alpine) — lightweight and secure base image
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Install openssl for Prisma runtime engine on Alpine
RUN apk add --no-cache openssl libc6-compat

# ─── Dependency Installation ─────────────────────────────────────────────────
# Copy package manifests and Prisma schema first for Docker layer caching
COPY package.json package-lock.json ./
COPY prisma/ ./prisma/

# Install dependencies and generate Prisma Client
RUN npm ci && npx prisma generate

# ─── Application Source ──────────────────────────────────────────────────────
# Copy application source code
COPY src/ ./src/

# Set production environment
ENV NODE_ENV=production
ENV PORT=5000

# Expose backend port
EXPOSE 5000

# Start server
CMD ["node", "src/server.js"]
