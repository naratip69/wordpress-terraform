variable "region" {
  type = string
  default = "us-east-1"
}

variable "availability_zone" {
  type = string
  default = "us-east-1f"
}

variable "ami" {
  type = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "bucket_name" {
  type = string
  default = "wordpress-s3"
}

variable "database_name" {
  type = string
  default = "wordpress"
}

variable "database_user" {
  type = string
  default = "username"
}

variable "database_pass" {
  type = string
  default = "password"
}

variable "admin_user" {
  type = string
  default = "admin"
}

variable "admin_pass" {
  type = string
  default = "admin"
}

variable "admin_email" {
  type = string
  default = "admin@admin.com"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "nat_subnet_cidr" {
  type = string
  default = "10.0.3.0/24"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
