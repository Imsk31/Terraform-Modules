module "vpc" {
  source = "vpc-module"
  vpc_cidr = var.vpc_cid
  instance_tenancy = var.instance_tenancy
  vpc_name = var.vpc_name
  igw_name = var.igw_name
  public_subnet_cidr = var.public-subnet-cidr
  private_subnet_cidr = var.private_subnet_cidr
  subnet_az = var.subnet-az
}