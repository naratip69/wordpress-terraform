#!/bin/bash

# Update package lists and upgrade installed packages
sudo apt update -y
sudo apt upgrade -y

# Install required dependencies
sudo apt install -y software-properties-common dirmngr

# Add the MariaDB 10.11 APT repository
sudo wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup --mariadb-server-version="10.11"

# Install MariaDB 10.11 server
sudo apt update -y
sudo apt install -y mariadb-server

# Start and enable the MariaDB service

sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation (Optional: Uncomment and follow prompts)
# sudo mysql_secure_installation

# Run MariaDB commands to create database and user

sudo mysql -u root <<EOF
CREATE DATABASE ${database_name};
CREATE USER '${database_user}'@'%' IDENTIFIED BY '${database_password}';

GRANT ALL PRIVILEGES ON wordpress.* TO '${database_user}'@'%';
FLUSH PRIVILEGES;
EXIT;
EOF

# Check MariaDB service status (optional)
sudo systemctl status mariadb --no-pager

