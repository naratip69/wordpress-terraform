resource "aws_instance" "wordpress-server" {
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  subnet_id = aws_subnet.App-Inet.id
  security_groups = aws_security_group.public-security-group
  user_data = templatefile("./wordpress.sh.tpl", {
    database_name = var.database_name
    database_user = var.database_user
    database_pass =  var.database_pass
    db_endpoint = aws_instace.db-server.private_ip 
    admin_user = var.admin_user
    admin_pass = var.admin_pass
    admin_email = var.admin_email
  })
  tags {
    Name = "midterm-wordpress-web-server"
  }

  depends_on = [aws_instance.wordpress-server]
}

resource "aws_instance" "db-server" {
  ami = var.ami
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  subnet_id = aws_subnet.App-DB.id
  security_groups = aws_security_group.private-security-group
  user_data = templatefile("./database.sh.tpl", {
    database_name = var.database_name
    database_user = var.database_user
    database_password = var.database_pass
  })
  tags {
    Name = "midterm-wordpress-db-server"
  }
}
