data "aws_availability_zones" "available" {
  state = "available"
  
}

###############
### VPC
###############
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

###############
### Public Subnets
###############
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
    Type = "public"
  }
}

###############
### Private Subnets
###############
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

###############
### Internet Gateway
###############
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

###############
### Route Table : Public
###############
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

###############
### Association : Subnets publics
###############
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)  # ← Autant d'associations que de subnets

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

###############
### Route Table : Private
###############
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

###############
### Association : Subnets privés 
###############
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}