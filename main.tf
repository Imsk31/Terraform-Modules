# -----------------------------
# VPC
# -----------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_name              = "${terraform.workspace}-${var.vpc_name}"
  vpc_cidr              = var.vpc_cidr

  public_subnets        = var.public_subnets
  private_subnets       = var.private_subnets

  nat_mode              = var.nat_mode
  nat_connectivity_type = var.nat_connectivity_type

  tags                  = local.final_tags

}

# -----------------------------
# Bastion Host
# -----------------------------

module "bastion" {
  source = "../../modules/bastion"

instance_name = "${terraform.workspace}-${var.instance_name}"
ami_id        = var.ami_id
instance_type = var.instance_type

subnet_id     = values(module.vpc.public_subnets)[0]
vpc_id        = module.vpc.vpc_id

volume_size   = var.volume_size
volume_type   = var.volume_type

tags          = local.final_tags
}

# -----------------------------
# RDS Instance
# -----------------------------

module "rds" {
  source = "../../modules/rds"

identifier              = "${terraform.workspace}-${var.identifier}"
rds_engine              = var.rds_engine
engine_version          = var.engine_version

instance_class          = var.instance_class
allocated_storage       = var.allocated_storage
storage_type            = var.storage_type
storage_encrypted       = var.storage_encrypted

multi_az                = var.multi_az
publicly_accessible     = var.publicly_accessible
subnet_ids              = values(module.vpc.private_subnets)
vpc_id                  = module.vpc.vpc_id
allowed_sg_ids          = [module.bastion.bastion_sg_id, module.eks.node_sg_id]

db_name                 = var.db_name
username                = var.username
password_wo             = var.password_wo
password_wo_version     = var.password_wo_version

snapshot_identifier     = "${terraform.workspace}-${var.identifier}-snapshot"
skip_final_snapshot     = var.skip_final_snapshot
deletion_protection     = var.deletion_protection

tags = local.final_tags
}

# -------------------------------------------------------
# EKS Module - Creates EKS cluster and node group
# -------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name            = var.cluster_name
  vpc_id                  = module.vpc.vpc_id
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  subnet_ids              = values(module.vpc.private_subnets)
  allowed_sg_ids          = [module.bastion.bastion_sg_id]

  desired_size            = var.desired_size
  max_size                = var.max_size
  min_size                = var.min_size
  instance_type           = var.eks_instance_type

  tags = var.tags
}
