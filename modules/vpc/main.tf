#----------------------------------------------------
# VPC 
#----------------------------------------------------

resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(
    {
      Name = var.vpc_name
    }, 
    var.tags)
}

#----------------------------------------------------
# Internet Gateway
#----------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    }, 
    var.tags)
}

#----------------------------------------------------
# Subnets
#----------------------------------------------------

# Create public subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.vpc_name}-public-${each.key}"
    }, 
    var.tags)
}

# Create private subnets
resource "aws_subnet" "private" {
  for_each          = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    {
      Name = "${var.vpc_name}-private-${each.key}"
    }, 
    var.tags)
}

#----------------------------------------------------
# NAT Gateway + Elastic IPs
#----------------------------------------------------

# Create Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
  for_each = toset(local.nat_keys)

  domain   = "vpc"

  tags = merge(
    {
      Name = "${var.vpc_name}-eip-${each.key}"
    }, 
    var.tags)
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat" {
  for_each          = toset(local.nat_keys)

  allocation_id     = aws_eip.nat[each.key].id
  connectivity_type = var.nat_connectivity_type


  # subnet selection logic
  subnet_id = (
    var.nat_mode == "single" || var.nat_mode == "regional"
    ? values(aws_subnet.public)[0].id
    : aws_subnet.public[each.key].id
  )


  # regional support (only when needed)
  availability_mode = var.nat_mode == "regional" ? "regional" : "zonal"

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-${each.key}"
    }, 
    var.tags)
}

#----------------------------------------------------
# Route Tables
#----------------------------------------------------

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id       = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-public-rt"
    }, 
    var.tags)
}


# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


# Private Route Table
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = (
      var.nat_mode == "single"   ? aws_nat_gateway.nat["shared"].id :
      var.nat_mode == "regional" ? aws_nat_gateway.nat["regional"].id :
      aws_nat_gateway.nat[each.key].id
    )
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-private-rt-${each.key}"
    }, 
    var.tags)
}


# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}