resource "aws_network_interface" "App-DB" {
  subnet = aws_subnet.App-DB.id
  security_groups = [aws_security_group.private-security-group.id]
  
  tags = {
    Name = "midterm-network-interface-App-DB"
  }
  attachment {
    instance = aws_instance.wordpress-server.id
    device_index = 1
  }
}

resource "aws_network_interface" "DB-Inet" {
  subnet = aws_subnet.DB-Inet.id
  security_groups = [aws_security_group.db-security-group.id]
  
  tags = {
    Name = "midterm-network-interface-DB-Inet"
  }
  attachment {
    instance = aws_instance.db-server.id
    device_index = 1
  }
}
