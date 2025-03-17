resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "midterm-nat-eip"
  }
}

resource "aws_eip" "app_eip" {
  domain = "vpc"
  tags = {
    Name = "midterm-app-eip"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id = aws_instance.wordpress-server.id
  allocation_id = aws_eip.app_eip.id
}
