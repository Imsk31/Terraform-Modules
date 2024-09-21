module "vpc" {
  source              = "./vpc_module"
  vpc_cidr            = var.vpc_cidr
  instance_tenancy    = var.instance_enancy
  vpc_name            = var.vpc_name
  igw_name            = var.igw_name
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  subnet_az           = var.subnet_az
}
