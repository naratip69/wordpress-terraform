resource "aws_security_group" "public-security-group" {
  name = "midterm-wordpress-public-security-group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    form_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tpc"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-security-group" {
  name = "midterm-wordpress-private-security-group"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "db-security-group" {
  name = "midterm-wordpress-db-security-group"
  vpc_id = aws_vpc.vpc.id
  
  engress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
