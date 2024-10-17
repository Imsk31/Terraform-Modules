terraform {
  backend "s3" {
    bucket = "31101999"
    key    = "demo-project/terraform.tfstate"
    region = "us-east-1"
  }
}