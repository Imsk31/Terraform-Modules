module "vpc" {
  source              = "./vpc-module"
  vpc_cidr            = var.vpc_cidr
  instance_tenancy    = var.instance_tenancy    
  vpc_name            = var.vpc_name            
  igw_name            = var.igw_name           
  public_subnet_cidr  = var.public_subnet_cidr 
  private_subnet_cidr = var.private_subnet_cidr
  subnet_az           = var.subnet_az           
  aws_region          = var.aws_region         
}
