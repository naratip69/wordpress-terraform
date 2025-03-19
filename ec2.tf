resource "aws_instance" "wordpress-server" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.my_key_pair.key_name
  availability_zone = var.availability_zone
  subnet_id = aws_subnet.App-Inet.id
  vpc_security_group_ids = [aws_security_group.public-security-group.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data = templatefile("./wordpress.sh.tpl", {
    database_name = var.database_name
    database_user = var.database_user
    database_pass =  var.database_pass
    db_endpoint = aws_instance.db-server.private_ip 
    admin_user = var.admin_user
    admin_pass = var.admin_pass
    admin_email = var.admin_email
    bucket_name = var.bucket_name
    wordpress_endpoint = aws_eip.app_eip.public_ip
    region = var.region
  })
  tags = {
    Name = "midterm-wordpress-web-server"
  }

  depends_on = [aws_instance.db-server, aws_iam_instance_profile.ec2_profile]
}

resource "aws_instance" "db-server" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.my_key_pair.key_name
  availability_zone = var.availability_zone
  subnet_id = aws_subnet.App-DB.id
  vpc_security_group_ids = [aws_security_group.private-security-group.id]
  user_data = templatefile("./database.sh.tpl", {
    database_name = var.database_name
    database_user = var.database_user
    database_password = var.database_pass
  })
  tags = {
    Name = "midterm-wordpress-db-server"
  }
}
