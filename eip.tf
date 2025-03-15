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
