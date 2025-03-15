resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnnet_id = aws_subnet.NAT-GW.id

  tags = {
    Name = "midterm-nat"
  }

  depends_on = [aws_internet_gateway.igw.id]
}
