aws_region = "us-east-1"
environment = "dev"
cluster_name = "eks-cluster"
cluster_version = "1.28"

node_group_name = "eks-node-group"
node_instance_types = ["t3.medium"]
node_disk_size = 20
node_desired_size = 2
node_max_size = 4
node_min_size = 1

vpc_cidr = "10.0.0.0/16"
vpc_tenency = "default"
vpc_name = "demo-VPC"
igw_name = "tf-igw"
availability_zones = [ "us-east-1a", "us-east-1b" ]
public_subnet_cidr = [ "10.0.6.0/24", "10.0.7.0/24" ]
private_subnet_cidr = [ "10.0.1.0/24", "10.0.2.0/24" ]

tags = {
  Terraform   = "true"
  Environment = "dev"
  Project     = "demo-project"
}

enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
endpoint_private_access = true
endpoint_public_access = true
enable_nat_gateway = true
single_nat_gateway = true





