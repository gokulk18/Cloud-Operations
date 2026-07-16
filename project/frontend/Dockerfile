# =============================================================================
# Cloud Operations Dashboard - Frontend (Node.js + Express)
# Multi-stage production build for AWS ECS Fargate
# =============================================================================

# ---- Stage 1: Install dependencies ---------------------------------------
FROM node:20-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json* ./

# Production-only dependencies, deterministic install where a lockfile exists.
RUN npm install --omit=dev

# ---- Stage 2: Production runtime image -------------------------------------
FROM node:20-alpine

WORKDIR /app

# Create a dedicated, unprivileged user - containers should never run as root.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY app.js ./
COPY public ./public

# Default configuration - all overridable at deploy time (e.g. via the ECS
# task definition) without rebuilding the image.
ENV NODE_ENV=production \
    API_PORT=3000 \
    ENVIRONMENT=production \
    APP_NAME="Cloud Operations Dashboard" \
    BACKEND_URL=http://backend:5000 \
    LOG_LEVEL=info

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

# Container-level health check - mirrors what the ALB target group and ECS
# service will use to determine task health.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:' + (process.env.API_PORT || 3000) + '/healthz', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "app.js"]
