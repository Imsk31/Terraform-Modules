
# -----------------------------
# VPC
# -----------------------------

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_name" {
  type    = string
  default = "vpc"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  description = "Map of AZ => CIDR"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of AZ => CIDR"
  type        = map(string)
}

variable "nat_mode" {
  type = string
}

variable "nat_connectivity_type" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Project = "terraform-modules"
    Owner   = "Shubham Kalekar"
  }
}

# -----------------------------
# EC2
# -----------------------------

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "bastion-host"
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type    = string
  default = "gp2"
}

# -----------------------------
# RDS
# -----------------------------

variable "identifier" {
  description = "Unique identifier for the RDS instance"
  type = string
}

variable "db_name" {
  description = "Name of the initial database to create"
  type = string
}

variable "rds_engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type = string
}

variable "engine_version" {
  description = "The version of the database engine"
  type = string
}

variable "instance_class" {
  description = "The instance type for the RDS instance"
  type = string
}

variable "allocated_storage" {
  description = "The amount of storage to allocate for the RDS instance"
  type = number
}

variable "storage_type" {
  description = "The type of storage to use for the RDS instance"
  type = string
}

variable "storage_encrypted" {
  description = "Whether to encrypt the storage for the RDS instance"
  type = bool
}

variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment for the RDS instance"
  type = bool
}

variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type = bool
}

variable "username" {
  description = "The username for the RDS instance"
  type      = string
  sensitive = true
}

variable "password_wo" {
  description = "The password for the RDS instance"
  type      = string
  sensitive = true
}

variable "password_wo_version" {
  description = "The version of the password for the RDS instance"
  type      = string
  sensitive = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip creating a final snapshot when deleting the RDS instance"
  type    = bool
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the RDS instance"
  type    = bool
}

#----------------------------------------------------
#EKS Module Variables                               
#----------------------------------------------------

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string 
}

variable "endpoint_public_access" {
  description = "Whether to enable public access to the EKS API endpoint"
  type        = bool
}

variable "endpoint_private_access" {
  description = "Whether to enable private access to the EKS API endpoint"
  type        = bool
}

variable "eks_instance_type" {
  description = "EC2 instance type for cluster nodes"
  type = string
}

variable "desired_size" {
  description = "Desired number of worker nodes in the node group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes in the node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes in the node group"
  type        = number
}