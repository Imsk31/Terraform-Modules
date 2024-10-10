terraform {
  backend "s3" {
    bucket = "31101999"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}