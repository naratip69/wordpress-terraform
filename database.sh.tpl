#!/bin/bash

# SSH keys to add
KEY1="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDbPsEKi9AjSgddGhxcB65B088RYXIOcvPDwiD38KnY"
KEY2="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL"

SSH_DIR="/home/$USER/.ssh"

AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

echo "Setting up SSH for $USER"

# Ensure ubuntu user exists (this should be the default user for EC2 Ubuntu AMI)
if ! id "$USER" &>/dev/null; then
  sudo useradd -m -s /bin/bash "$USER"
fi

# Create .ssh directory if it doesn't exist
sudo mkdir -p "$SSH_DIR"
sudo chmod 700 "$SSH_DIR"

# Add first SSH key to authorized_keys
echo "$KEY1" | sudo tee -a "$AUTHORIZED_KEYS" > /dev/null

# Add second SSH key to authorized_keys
echo "$KEY2" | sudo tee -a "$AUTHORIZED_KEYS" > /dev/null

# Set the correct permissions
sudo chmod 600 "$AUTHORIZED_KEYS"

# Set the correct ownership for the .ssh directory and authorized_keys file
sudo chown -R "$USER:$USER" "$SSH_DIR"


sudo ip route change default via 10.0.2.1 dev enX1 metric 100

# Update package lists and upgrade installed packages
sudo apt update -y
sudo apt upgrade -y

# Install required dependencies
sudo apt install -y software-properties-common dirmngr

# Add the MariaDB 10.11 repository
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mirrors.kernel.org/mariadb/repo/10.11/ubuntu $(lsb_release -cs) main"

# Update package index again after adding the repository
sudo apt update -y

# Install MariaDB server
sudo apt install -y mariadb-server
# Start and enable the MariaDB service

sudo systemctl start mariadb
sudo systemctl enable mariadb

# Configure MariaDB to listen on all IPs
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Restart MariaDB to apply changes
sudo systemctl restart mariadb

# Secure MariaDB installation (Optional: Uncomment and follow prompts)
# sudo mysql_secure_installation

# Run MariaDB commands to create database and user

sudo mysql -u root <<EOF
CREATE DATABASE ${database_name};
CREATE USER '${database_user}'@'%' IDENTIFIED BY '${database_password}';

GRANT ALL PRIVILEGES ON ${database_name}.* TO '${database_user}'@'%';
FLUSH PRIVILEGES;
EXIT;
EOF


# Check MariaDB service status (optional)
sudo systemctl status mariadb --no-pager
