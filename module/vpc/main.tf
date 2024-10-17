resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = var.vpc_tenency

  tags = {
    name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    name = var.igw_name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.public_subnet_cidr)
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true
  
  tags = { 
    value ="public_subnet"
  }
}

resource "aws_route_table" "vpc_pub_rt" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    value = "public subnet rt"
  }
}

resource "aws_route_table_association" "vpc_pub_rt_assocication" {
  count = length(var.public_subnet_cidr)
  route_table_id = aws_route_table.vpc_pub_rt[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id
}


resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.private_subnet_cidr)
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = false

tags = {
  value = "private_subnet"
}
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  network_border_group = var.aws_region 
}

resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.public_subnet[0].id
  connectivity_type = "public"
  allocation_id = aws_eip.nat_eip.id
  
tags = {
  value = "Nat Gateway for terraform vpc private subnet"
}
}

resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.private_subnet_cidr)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    value = "private subnet rt"
  }
  
}

resource "aws_route_table_association" "vpc_pri_rt_association" {
  count = length(var.private_subnet_cidr)
  route_table_id = aws_route_table.pri_rt[count.index].id
  subnet_id = aws_subnet.private_subnet[count.index].id
}




