
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.54.0"
    }
  }

  # Remote state in S3, with state locking. State locking uses S3's own
  # native conditional-write locking (use_lockfile = true, requires
  # Terraform >= 1.10) - no separate DynamoDB table is required or created.
  backend "s3" {
    bucket       = "cloud-ops-dashboard-tfstate-902664897239"
    key          = "cloud-ops-dashboard/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
