'use strict';

// Minimal structured (JSON-line) logger - consistent with the backend's

const express = require('express');
const path = require('path');

const API_PORT = process.env.API_PORT || 3000;
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';
const APP_NAME = process.env.APP_NAME || 'Cloud Operations Dashboard';
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5000';
const LOG_LEVEL = (process.env.LOG_LEVEL || 'info').toLowerCase();

const LOG_LEVELS = ['error', 'warn', 'info', 'debug'];

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

app.use((req, res, next) => {
  log('info', `Incoming request: ${req.method} ${req.path}`);
  res.on('finish', () => {
    log('info', `Response status: ${res.statusCode}`, { path: req.path });
  });
  next();
});

app.use(express.static(path.join(__dirname, 'public')));

app.get('/healthz', (_req, res) => {
  res.status(200).json({ status: 'healthy', service: 'frontend' });
});

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

app.use((err, _req, res, _next) => {
  log('error', `Unhandled error: ${err.message}`);
  res.status(500).json({ error: 'Internal Server Error' });
});

app.listen(API_PORT, '0.0.0.0', () => {
  log('info', `${APP_NAME} frontend started in ${ENVIRONMENT} mode on port ${API_PORT}`, {
    backendUrl: BACKEND_URL,
  });
});
