
variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
}

provider "aws" {
  region = var.region
}

terraform {
  backend "local" {
    path = "statefile/terraform.tfstate"
  }
}

resource "aws_s3_bucket" "main" {
  bucket               = "terraform-statefile-${var.region}-8805"
  region               = var.region

  tags = {
    Name = "My Terraform S3 Bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership =  "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_ownership_controls.main]

  bucket     = aws_s3_bucket.main.id
  acl        = "private"
}