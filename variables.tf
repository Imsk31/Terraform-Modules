variable "aws_region" {
  type = string
  description = "AWS REGION"
}
variable "vpc_cidr" {
  type = string
  description = "VPC CIDR"
}
variable "vpc_tenency" {
  type = string
  description = "Instance Tenancy For VPC"
}
variable "vpc_name" {
  description = "VPC Name"
  type = string
}
variable "igw_name" {
  type = string
  description = "IGW Name"
}

variable "subnet-az" {
  type = list(string)
  description = "Availability Zones"
}
variable "public-subnet-cidr" {
  type = list(string)
  description = "CIDR for public subnet"
}
variable "private-subnet-cidr" {
  type = list(string)
  description = "CIDR for private subnet"
}
variable "backend_path" {
  type = string
  description = "backend path"
}


