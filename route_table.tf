resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "midterm-public-route-table"
  }
}

resource "aws_route_table" "nat-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "midterm-nat-route-table"
  }
}
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat.nat-gateway.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "midterm-private-route-table"
  }
  depends_on = [aws_nat.nat-gateway]
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.App-Inet.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.NAT-GW.id
  route_table_id = aws_route_table.nat-route-table.id
}
resource "aws_route_table_association" "c" {
  subnet_id = aws_subnet.DB-Inet.id
  route_table_id = aws_route_table.private-route-table.id
}
