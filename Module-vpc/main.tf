resource "aws_vpc" "terraform_vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = var.vpc_tenency

  tags = {
    name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    name = var.igw_name
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.terraform_vpc.id
  count = length(var.cidr-public-subnet)
  cidr_block = var.cidr-public-subnet[count.index]
  availability_zone = element(var.subnet-az, count.index)
  map_public_ip_on_launch = true
  
  tags = { 
    value ="public-subnet"
  }
}



