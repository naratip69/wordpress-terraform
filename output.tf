output "app_elastic_ip" {
  value = aws_eip.app_eip.public_ip
}
output "nat_elastic_ip" {
  value = aws_eip.nat_eip.public_ip
}
output "db_private_ip" {
  value =  aws_instance.db-server.private_ip
}
