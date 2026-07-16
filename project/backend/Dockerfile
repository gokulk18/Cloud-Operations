# =============================================================================
# Cloud Operations Dashboard - Backend (Flask + Gunicorn)
# Multi-stage production build for AWS ECS Fargate
# =============================================================================

# ---- Stage 1: Build Python dependencies --------------------------------
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

# Install into the user site-packages dir so it can be copied verbatim
# into the slim runtime image without carrying build tooling along.
RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Stage 2: Production runtime image ----------------------------------
FROM python:3.12-slim

WORKDIR /app

# Create a dedicated, unprivileged user - containers should never run as root.
RUN groupadd --system appuser && useradd --system --gid appuser appuser

# Bring in the pre-built dependencies from the builder stage only.
COPY --from=builder /root/.local /home/appuser/.local

# Copy application source.
COPY app.py .

ENV PATH="/home/appuser/.local/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Default configuration - all overridable at deploy time (e.g. via the ECS
# task definition) without rebuilding the image.
ENV API_PORT=5000 \
    ENVIRONMENT=production \
    APP_NAME="Cloud Operations Dashboard" \
    LOG_LEVEL=INFO

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

# Container-level health check - mirrors what the ALB target group and ECS
# service will use to determine task health.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import os,urllib.request; urllib.request.urlopen(f'http://localhost:{os.environ.get(\"API_PORT\",\"5000\")}/health', timeout=3)" || exit 1

# Run under Gunicorn - never use Flask's built-in development server in production.
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${API_PORT} --workers 2 --threads 4 --access-logfile - --error-logfile - app:app"]
