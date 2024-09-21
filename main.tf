module "vpc" {
  source              = "./vpc-module"
  vpc_cidr            = var.vpc_cidr
  instance_tenancy    = var.instance-enancy
  vpc_name            = var.vpc-name
  igw_name            = var.igw-name
  public_subnet_cidr  = var.public-subnet-cidr
  private_subnet_cidr = var.private-subnet-cidr
  subnet_az           = var.subnet-az
  aws_region          = var.aws-region
}
