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
  count = length(var.public-subnet-cidr)
  cidr_block = var.public-subnet-cidr[count.index]
  availability_zone = element(var.subnet-az, count.index)
  map_public_ip_on_launch = true
  
  tags = { 
    value ="public-subnet"
  }
}

resource "aws_route_table" "terraform-vpc-pub-sub-rt" {
  vpc_id = aws_vpc.terraform_vpc.id
  count = length(var.public-subnet-cidr)

  tags = {
    value = "public subnet rt"
  }
}

resource "aws_route_table_association" "terraform-vpc-pub-rt-assocication" {
  route_table_id = aws_route_table.terraform-vpc-pub-sub-rt.id
  subnet_id = aws_subnet.public-subnet.0.id
  count = length(var.public-subnet-cidr)
}



resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.terraform_vpc.id
  count = length(var.private-subnet-cidr)
  cidr_block = var.private-subnet-cidr[count.index]
  availability_zone = element(var.subnet-az, count.index)
  map_public_ip_on_launch = false

tags = {
  value = "private-subnet"
}
}

resource "aws_eip" "nat-eip" {
  domain = vpc
  network_border_group = var.aws_region 
}

resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.public-subnet.0.id
  connectivity_type = "public"
  allocation_id = aws_eip.nat-eip.id
  
tags = {
  value = "Nat Gateway"
}
}





