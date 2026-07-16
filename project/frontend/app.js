'use strict';

/**
 * Cloud Operations Dashboard - Frontend server
 *
 * Serves the static dashboard (HTML/CSS/vanilla JS) and exposes a small set
 * of same-origin "/api/*" routes that proxy to the Flask backend. Proxying
 * server-side (instead of having the browser call the backend directly)
 * keeps BACKEND_URL out of client-facing code, avoids CORS entirely, and
 * matches how this service will sit behind an ALB in ECS - the browser only
 * ever talks to this one origin.
 */

const express = require('express');
const path = require('path');

// ---------------------------------------------------------------------------
// Configuration (all values sourced from environment variables - no
// hardcoded hosts/ports so the same image works in any environment/region)
// ---------------------------------------------------------------------------
const API_PORT = process.env.API_PORT || 3000;
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';
const APP_NAME = process.env.APP_NAME || 'Cloud Operations Dashboard';
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5000';
const LOG_LEVEL = (process.env.LOG_LEVEL || 'info').toLowerCase();

const LOG_LEVELS = ['error', 'warn', 'info', 'debug'];

/** Minimal structured (JSON-line) logger - consistent with the backend's
 * logging shape and easy for CloudWatch Logs to index. */
function log(level, message, meta = {}) {
  const configuredIdx = LOG_LEVELS.indexOf(LOG_LEVEL);
  const levelIdx = LOG_LEVELS.indexOf(level);
  if (levelIdx > configuredIdx) return;

  console.log(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      level,
      service: 'frontend',
      message,
      ...meta,
    })
  );
}

const app = express();
app.disable('x-powered-by');

// ---- Request/response logging ----------------------------------------------
app.use((req, res, next) => {
  log('info', `Incoming request: ${req.method} ${req.path}`);
  res.on('finish', () => {
    log('info', `Response status: ${res.statusCode}`, { path: req.path });
  });
  next();
});

// ---- Static dashboard assets -----------------------------------------------
app.use(express.static(path.join(__dirname, 'public')));

// ---- Frontend's own liveness endpoint --------------------------------------
// Used by the ECS task health check / ALB target group for the frontend
// service itself (separate from the backend's /health).
app.get('/healthz', (_req, res) => {
  res.status(200).json({ status: 'healthy', service: 'frontend' });
});

// ---- Backend proxy routes ---------------------------------------------------
async function proxyToBackend(backendPath, res) {
  try {
    const response = await fetch(`${BACKEND_URL}${backendPath}`, {
      signal: AbortSignal.timeout(5000),
    });
    const data = await response.json();
    res.status(response.status).json(data);
  } catch (err) {
    log('error', `Failed to reach backend at ${backendPath}: ${err.message}`);
    res.status(502).json({ status: 'unhealthy', error: 'Backend unreachable' });
  }
}

app.get('/api/health', (_req, res) => proxyToBackend('/health', res));
app.get('/api/info', (_req, res) => proxyToBackend('/info', res));
app.get('/api/time', (_req, res) => proxyToBackend('/time', res));
app.get('/api/metrics', (_req, res) => proxyToBackend('/metrics', res));

// ---- Error handling ----------------------------------------------------------
app.use((err, _req, res, _next) => {
  log('error', `Unhandled error: ${err.message}`);
  res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(API_PORT, '0.0.0.0', () => {
  log('info', `${APP_NAME} frontend started in ${ENVIRONMENT} mode on port ${API_PORT}`, {
    backendUrl: BACKEND_URL,
  });
});
