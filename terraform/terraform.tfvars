
aws_region   = "us-east-1"
project_name = "cloud-ops-dashboard"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
]


application_port = 3000

# The frontend image URI is published to this SSM parameter by the CI/CD
# pipeline after each build - Terraform reads it at plan time instead of
# hardcoding an image tag here. Must match SSM_FRONTEND_PARAM in
# .github/workflows/build-image.yml (the actual writer of this parameter).
image_ssm_parameter_name = "/ecs/frontend-image-uri"

container_name = "frontend"

# 256 CPU units (0.25 vCPU) / 512 MiB memory - smallest valid Fargate size,
# sufficient for this lightweight demo app.
cpu    = 256
memory = 512

# Auto scale between 1 and 4 tasks, targeting 60% average CPU utilization.
min_capacity           = 1
max_capacity           = 4
target_cpu_utilization = 60

# The backend Flask API - reachable only from the frontend, over Service
# Connect, never directly from the ALB. 5000 matches backend/app.py's
# default API_PORT (see project/backend/Dockerfile).
backend_image_ssm_parameter_name = "/ecs/backend-image-uri"
backend_container_name           = "backend"
backend_container_port           = 5000
