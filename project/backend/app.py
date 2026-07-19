"""
Cloud Operations Dashboard - Backend API

A minimal, stateless Flask REST API designed to be run under Gunicorn inside
a Docker container on AWS ECS Fargate, sitting behind an Application Load
Balancer. Every setting is read from the environment so the same image can
be promoted across dev/stage/prod without rebuilding.
"""

import logging
import os
import platform
import socket
import threading
import time
from datetime import datetime, timezone

import psutil
from flask import Flask, jsonify, request

API_PORT = int(os.environ.get("API_PORT", "5000"))
ENVIRONMENT = os.environ.get("ENVIRONMENT", "development")
APP_NAME = os.environ.get("APP_NAME", "Cloud Operations Dashboard")
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO").upper()

logging.basicConfig(
    level=LOG_LEVEL,
    format=(
        '{"timestamp":"%(asctime)s","level":"%(levelname)s",'
        '"service":"backend","message":"%(message)s"}'
    ),
    datefmt="%Y-%m-%dT%H:%M:%S%z",
)
logger = logging.getLogger(APP_NAME)

app = Flask(__name__)

START_TIME = time.time()
_request_count = 0
_request_count_lock = threading.Lock()

def _increment_request_count() -> int:
    """Thread-safe increment of the per-worker request counter."""
    global _request_count
    with _request_count_lock:
        _request_count += 1
        return _request_count

def _format_uptime(seconds: float) -> str:
    """Render an uptime duration in seconds as a human-readable string."""
    seconds = int(seconds)
    hours, remainder = divmod(seconds, 3600)
    minutes, secs = divmod(remainder, 60)
    return f"{hours}h {minutes}m {secs}s"

@app.before_request
def _log_incoming_request():
    _increment_request_count()
    logger.info("Incoming request: %s %s", request.method, request.path)

@app.after_request
def _log_response(response):
    logger.info(
        "Response status: %s for %s %s",
        response.status_code,
        request.method,
        request.path,
    )
    return response

@app.errorhandler(404)
def _not_found(_error):
    return jsonify(error="Not Found"), 404

@app.errorhandler(Exception)
def _handle_unexpected_error(error):
    logger.error("Unhandled exception: %s", error, exc_info=True)
    return jsonify(error="Internal Server Error"), 500

@app.route("/")
def root():
    """Basic liveness/identity endpoint."""
    return jsonify(application=APP_NAME, status="Running")

@app.route("/health")
def health():
    """
    Health check endpoint consumed by:
      - ECS container health checks
      - ALB target group health checks
      - CloudWatch synthetic/alarm checks

    Must return HTTP 200 whenever the process is able to serve traffic.
    """
    return (
        jsonify(
            status="healthy",
            service="backend",
            timestamp=datetime.now(timezone.utc).isoformat(),
        ),
        200,
    )

@app.route("/info")
def info():
    """Container/runtime metadata - useful for confirming which task/AZ
    served a given request when validating load balancing and scaling."""
    return jsonify(
        hostname=socket.gethostname(),
        python_version=platform.python_version(),
        environment=ENVIRONMENT,
        uptime=_format_uptime(time.time() - START_TIME),
        request_count=_request_count,
    )

@app.route("/time")
def current_time():
    """Returns the current UTC time as tracked by the container."""
    now = datetime.now(timezone.utc)
    return jsonify(utc_time=now.isoformat(), unix_timestamp=int(now.timestamp()))

@app.route("/metrics")
def metrics():
    """Lightweight resource metrics, handy for manually validating that
    Auto Scaling policies (CPU/memory driven) are reacting correctly."""
    return jsonify(
        cpu_usage=f"{psutil.cpu_percent(interval=0.1)}%",
        memory_usage=f"{psutil.virtual_memory().percent}%",
        request_count=_request_count,
    )

if __name__ == "__main__":

    logger.info(
        "Starting %s in %s mode on port %s (dev server)",
        APP_NAME,
        ENVIRONMENT,
        API_PORT,
    )
    app.run(host="0.0.0.0", port=API_PORT)
