provider "aws" {
  region = "us-east-1"  # Adjust to your preferred region
}

# Declare variables
variable "environment" {
  description = "The environment for the deployment (e.g., development, staging, production)"
  type        = string
}

variable "bucket_name_suffix" {
  description = "Suffix for the S3 bucket name"
  type        = string
}

variable "bucket_versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
}

# Terraform backend configuration
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-parth"
    key            = "ProjectA/terraform/state"  # Key for ProjectA state file
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

# Sample S3 bucket resource for ProjectA
resource "aws_s3_bucket" "project_a_bucket" {
  bucket = "${var.bucket_name_suffix}-${random_id.bucket_suffix.hex}"

  versioning {
    enabled = var.bucket_versioning_enabled
  }

  tags = {
    Name        = "ProjectA Sample S3 Bucket"
    Environment = var.environment
  }
}

# Generate a random suffix for the bucket name to ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Output the S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.project_a_bucket.bucket
}
