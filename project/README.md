# Cloud Operations Dashboard

A deliberately simple two-service web application used to demonstrate a
production AWS deployment pipeline: **Docker → GitHub Container Registry →
ECS Fargate → Application Load Balancer → CloudWatch → Auto Scaling**,
provisioned with **Terraform** and built by **GitHub Actions**.

The business logic is intentionally trivial — a health/status dashboard —
so that all attention goes to the infrastructure and delivery pipeline
around it, not the application itself.

## Architecture

```
Browser
   │
   ▼
┌─────────────────────┐   BACKEND_URL (server-side only)   ┌─────────────────────┐
│  frontend service    │ ───────────────────────────────▶ │  backend service     │
│  Node.js + Express    │                                    │  Python + Flask API   │
│  serves static UI     │ ◀─────────────────────────────── │  runs under Gunicorn  │
│  proxies /api/*        │            JSON responses         │                       │
└─────────────────────┘                                    └─────────────────────┘
      GET /healthz                                                GET /health
   (own liveness check)                                    (ALB / ECS health check)
```

The browser only ever talks to the frontend's origin. The frontend proxies
`/api/*` calls to the backend using `BACKEND_URL`, so the backend's address
never needs to be exposed to client-side JavaScript — this also sidesteps
CORS and matches how the two services would be wired together behind an ALB
or via ECS Service Connect / Cloud Map in AWS.

Both services are **stateless** (no database, no sessions, no local writes),
so any number of Fargate tasks can run concurrently and be freely
scaled/replaced behind the load balancer.

## Project structure

```
project/
├── frontend/
│   ├── app.js              # Express server + /api/* proxy to backend
│   ├── package.json
│   ├── Dockerfile          # multi-stage Node build, non-root user
│   ├── .dockerignore
│   └── public/
│       ├── index.html      # dashboard markup
│       ├── styles.css      # dashboard styling
│       └── app.js          # browser-side dashboard logic
├── backend/
│   ├── app.py               # Flask REST API
│   ├── requirements.txt
│   ├── Dockerfile           # multi-stage Python build, Gunicorn, non-root user
│   └── .dockerignore
├── docker-compose.yml       # local two-service stack
├── .github/workflows/
│   └── docker-build-push.yml # builds + pushes both images to GHCR
└── README.md
```

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Node.js, Express, HTML, CSS, vanilla JavaScript |
| Backend | Python, Flask, Gunicorn |
| Metrics | psutil |
| Container runtime | Docker (multi-stage builds) |
| Local orchestration | Docker Compose |
| Target platform | AWS ECS Fargate behind an Application Load Balancer |

No frontend framework, database, auth layer, or message broker is used —
by design, to keep the focus on the deployment pipeline.

## Features

- **Home dashboard** — title, live deployment status badge, live UTC clock,
  and last API response status.
- **Health status card** — polls `/api/health` (proxied to the backend's
  `/health`) every 10 seconds and shows Healthy / Unhealthy.
- **System information card** — hostname, environment, Python version,
  current time, request count, and uptime, sourced from the backend `/info`
  endpoint.
- **API test console** — buttons to call `/health`, `/info`, `/time`, and
  `/metrics` on demand, with the raw JSON response and latency shown inline.
- **Auto-refresh** — health and system info refresh every 10 seconds without
  a page reload.
- **Responsive layout** — CSS grid cards, no external UI framework, honors
  light/dark color scheme.

## Backend API reference

| Method | Path | Description |
|---|---|---|
| GET | `/` | Application identity: `{"application": "...", "status": "Running"}` |
| GET | `/health` | Health check consumed by ECS/ALB/CloudWatch. Always `200` while healthy. |
| GET | `/info` | Hostname, Python version, environment, uptime, request count. |
| GET | `/time` | Current UTC time (ISO 8601 + Unix timestamp). |
| GET | `/metrics` | CPU and memory usage (via `psutil`) and request count. |

The frontend exposes the same shape under `/api/health`, `/api/info`,
`/api/time`, `/api/metrics` (proxied), plus its own `/healthz` for its own
container liveness check.

## Configuration (environment variables)

Nothing is hardcoded — every port, URL, and label is read from the
environment so the same images can be promoted across environments without
rebuilding.

**Backend**

| Variable | Default | Purpose |
|---|---|---|
| `API_PORT` | `5000` | Port Gunicorn binds to. |
| `ENVIRONMENT` | `development` | Reported by `/info`; set per deployment (e.g. `staging`, `production`). |
| `APP_NAME` | `Cloud Operations Dashboard` | Used in logs and the `/` response. |
| `LOG_LEVEL` | `INFO` | Python logging level. |

**Frontend**

| Variable | Default | Purpose |
|---|---|---|
| `API_PORT` | `3000` | Port the Express server binds to. |
| `ENVIRONMENT` | `development` | Reported in logs. |
| `APP_NAME` | `Cloud Operations Dashboard` | Used in logs. |
| `BACKEND_URL` | `http://localhost:5000` | Base URL the frontend proxies `/api/*` to. In ECS this points at the backend service's internal DNS name (Cloud Map / internal ALB). |
| `LOG_LEVEL` | `info` | Node logging verbosity (`error`, `warn`, `info`, `debug`). |

## Running locally

### Option A — Docker Compose (recommended)

```bash
cd project
docker compose up --build
```

- Frontend dashboard: http://localhost:3000
- Backend API directly: http://localhost:5000

Both services define container `HEALTHCHECK`s; `docker compose ps` will show
`healthy` once each passes.

### Option B — run each service natively

Backend:

```bash
cd project/backend
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
API_PORT=5000 ENVIRONMENT=development python app.py
```

Frontend:

```bash
cd project/frontend
npm install
API_PORT=3000 BACKEND_URL=http://localhost:5000 npm start
```

## Docker images

Both Dockerfiles use **multi-stage builds** and run as a **non-root user**:

- `backend/Dockerfile`: installs Python dependencies in a builder stage,
  copies only the resulting packages + source into a slim runtime stage, and
  serves the app with **Gunicorn** (never the Flask dev server).
- `frontend/Dockerfile`: installs production npm dependencies in a builder
  stage, then copies `node_modules` + source into a slim `node:alpine`
  runtime stage.

Both images declare a `HEALTHCHECK` that exercises the same endpoint ECS and
the ALB will use, so `docker ps` / `docker compose ps` reflect real
readiness.

## Deploying to AWS ECS Fargate

This app is built to drop directly into a standard ECS Fargate setup:

1. **Build & publish images** — the included GitHub Actions workflow
   (`.github/workflows/docker-build-push.yml`) builds both images and pushes
   them to **GitHub Container Registry (GHCR)** on every push to `main`,
   tagged with both `latest` and the commit SHA. Point your ECS task
   definitions at `ghcr.io/<org>/<repo>/cloud-ops-dashboard-frontend` and
   `...-backend`.
2. **Task definitions** — one Fargate task definition per service. Set the
   environment variables above via the task definition's `environment`
   block (or `secrets` for anything sensitive). Map container port `3000`
   (frontend) / `5000` (backend).
3. **Health checks** — configure the ECS container health check and the
   **ALB target group** health check to use:
   - Frontend: `GET /healthz` → expect `200`
   - Backend: `GET /health` → expect `200`
4. **Load balancing** — put the frontend service behind a public-facing
   ALB. The backend can sit behind an **internal** ALB or be reached via
   **ECS Service Connect / AWS Cloud Map**, with the frontend's
   `BACKEND_URL` pointing at that internal DNS name — no code changes
   required.
5. **CloudWatch** — both services log structured JSON lines to stdout/stderr,
   which the `awslogs` driver forwards to CloudWatch Logs automatically.
   Use the JSON `level`/`message`/`service` fields for CloudWatch Logs
   Insights queries and alarms (e.g. alert on repeated `"level":"error"`).
6. **Auto Scaling** — attach an Application Auto Scaling policy to each ECS
   service on CPU/memory utilization (Fargate task-level metrics from
   CloudWatch). The `/metrics` endpoint is provided so you can manually
   verify scaling behavior under load alongside the CloudWatch-driven
   policy.
7. **Terraform** — provision the ECR/GHCR pull permissions, ECS
   cluster/service/task definitions, ALB + target groups + listener rules,
   security groups, CloudWatch log groups, and Auto Scaling policies as
   Terraform resources; feed the image tag produced by the GitHub Actions
   workflow into the task definition's container image via a variable.

## Why the design choices behind this app fit ECS Fargate

- **Stateless** — no database, sessions, or local file writes; any task can
  serve any request, and tasks can be replaced or scaled at will.
- **Configurable via environment only** — no hardcoded hosts/ports, so the
  same image is promoted across environments unmodified.
- **Non-root containers** — both Dockerfiles create and switch to an
  unprivileged user.
- **Distinct liveness vs. dependency health** — the frontend's `/healthz`
  reports only its own liveness (so the ALB doesn't cycle frontend tasks
  just because the backend is briefly unavailable); the backend's `/health`
  is what represents API health.
- **Structured JSON logs** — every request/response and startup/error event
  is logged as a single JSON line, ready for CloudWatch Logs Insights.
