resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "midterm-wordpress-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "midterm-wordpress-igw"
  }
}

# Public subnet
resource "aws_subnet" "App-Inet" {
   vpc_id = aws_vpc.vpc.id
   cidr_block = var.public_subnet_cidr
   availability_zone = var.availability_zone
   tags = {
      Name = "App-Inet"
  }
}

# Private subnet
resource "aws_subnet" "App-DB" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "App-DB"
  }
}

# NAT subnet
resource "aws_subnet" "NAT-GW" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.nat_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "NAT-GW"
  }
}
