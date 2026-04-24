terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    region = "ap-south-1"
    bucket = "terraform-statefile-ap-south-1-8805"
    key = "statefile/terraform.tfstate"
    use_lockfile = true
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}