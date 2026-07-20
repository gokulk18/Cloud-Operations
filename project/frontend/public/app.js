'use strict';

const HEALTH_REFRESH_INTERVAL_MS = 10000;

const $ = (id) => document.getElementById(id);

function setDeploymentStatus(healthy) {
  const badge = $('deployment-status');
  if (healthy) {
    badge.textContent = 'Deployment Active';
    badge.className = 'badge badge-healthy';
  } else {
    badge.textContent = 'Deployment Issue Detected';
    badge.className = 'badge badge-unhealthy';
  }
}

function setHealthIndicator(healthy) {
  const indicator = $('health-indicator');
  const text = $('health-text');
  indicator.className = `status-indicator ${healthy ? 'status-healthy' : 'status-unhealthy'}`;
  text.textContent = healthy ? 'Healthy' : 'Unhealthy';
}

async function refreshHealth() {
  try {
    const res = await fetch('/api/health');
    const data = await res.json();
    const healthy = res.ok && data.status === 'healthy';

    setHealthIndicator(healthy);
    setDeploymentStatus(healthy);
    $('health-timestamp').textContent = `Last checked: ${new Date().toLocaleTimeString()}`;
    $('api-status').textContent = `${res.status} ${res.ok ? 'OK' : 'ERROR'}`;
    $('api-status-detail').textContent = 'Most recent response from /api/health';
  } catch (err) {
    setHealthIndicator(false);
    setDeploymentStatus(false);
    $('api-status').textContent = 'Unreachable';
    $('api-status-detail').textContent = err.message;
  }
}

async function refreshInfo() {
  try {
    const res = await fetch('/api/info');
    const data = await res.json();
    $('info-hostname').textContent = data.hostname ?? '--';
    $('info-environment').textContent = data.environment ?? '--';
    $('info-python').textContent = data.python_version ?? '--';
    $('info-time').textContent = new Date().toISOString();
    $('info-requests').textContent = data.request_count ?? '--';
    $('info-uptime').textContent = data.uptime ?? '--';
  } catch (err) {
    console.error('Failed to load system info:', err.message);
  }
}

function tickClock() {
  $('server-time').textContent = new Date().toISOString().replace('T', ' ').replace('Z', ' UTC');
}

function wireApiConsole() {
  document.querySelectorAll('[data-endpoint]').forEach((button) => {
    button.addEventListener('click', async () => {
      const endpoint = button.getAttribute('data-endpoint');
      const responseBox = $('api-response');
      responseBox.textContent = `Requesting ${endpoint}...`;

      try {
        const start = performance.now();
        const res = await fetch(endpoint);
        const data = await res.json();
        const elapsedMs = Math.round(performance.now() - start);
        responseBox.textContent = `${res.status} ${res.statusText} (${elapsedMs}ms)\n\n${JSON.stringify(data, null, 2)}`;
      } catch (err) {
        responseBox.textContent = `Request failed: ${err.message}`;
      }
    });
  });
}

function init() {
  wireApiConsole();
  tickClock();
  refreshHealth();
  refreshInfo();

  setInterval(tickClock, 1000);
  setInterval(refreshHealth, HEALTH_REFRESH_INTERVAL_MS);
  setInterval(refreshInfo, HEALTH_REFRESH_INTERVAL_MS);
}

document.addEventListener('DOMContentLoaded', init);
