#!/bin/bash

# Update package lists and upgrade installed packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y build-essential libxml2-dev libssl-dev libcurl4-openssl-dev \
libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libicu-dev libbz2-dev \
libmcrypt-dev libreadline-dev libmysqlclient-dev libxslt-dev libzip-dev wget apache2

# Download PHP 8.3 source code
wget https://www.php.net/distributions/php-8.3.0.tar.bz2
tar -xjf php-8.3.0.tar.bz2
cd php-8.3.0


# Configure PHP build options
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php --enable-bcmath --enable-fpm --with-openssl --with-curl --enable-mbstring --enable-soap --enable-sockets --with-xsl --with-bz2

# Compile PHP
make -j$(nproc)

# Install PHP
sudo make install

# Set up PHP configuration
sudo cp php.ini-production /usr/local/php/lib/php.ini
sudo cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf

# Configure Apache to use PHP 8.3
sudo apt install -y libapache2-mod-php
sudo systemctl restart apache2

# Configure Apache to use PHP 8.3
sudo apt install -y libapache2-mod-php
sudo systemctl restart apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

# Start Apache service
sudo systemctl start apache2

# Update system PATH to include PHP binary
echo 'export PATH=$PATH:/usr/local/php/bin' >> ~/.bashrc
source ~/.bashrc

# Download and install WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz  # Clean up unnecessary files

# Set the correct file permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Copy the sample WordPress configuration file
sudo cp wp-config-sample.php wp-config.php

# Configure database connection settings in wp-config.php
sudo sed -i "s/define( 'DB_NAME', .*/define( 'DB_NAME', '${database_name}' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_USER', .*/define( 'DB_USER', '${database_user}' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_PASSWORD', .*/define( 'DB_PASSWORD', '${database_pass}' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_HOST', .*/define( 'DB_HOST', '${db_endpoint}' );/" /var/www/html/wp-config.php

# Install WP-CLI to automate WordPress setup
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Create the WordPress admin user
sudo -u www-data wp core install --path=/var/www/html --url="http://your-server-ip" --title="My WordPress Site" --admin_user="${admin_user}" --admin_password="${admin_pass}" --admin_email="${admin_email}"

# Restart Apache to apply the changes
sudo systemctl restart apache2

# Define the username and the SSH public key to add
USER="ubuntu"  # Change this to the appropriate username
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress"

# Create the .ssh directory if it does not exist
SSH_DIR="/home/$USER/.ssh"
if [ ! -d "$SSH_DIR" ]; then
  echo "Creating .ssh directory for $USER"
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
fi

# Add the public key to the authorized_keys file
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
echo "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS"

# Set the correct permissions for the authorized_keys file
chmod 600 "$AUTHORIZED_KEYS"

# Inform the user that the key has been added
echo "Public SSH key has been added to $USER's authorized_keys."

# Ensure proper ownership of the .ssh folder and its contents
chown -R $USER:$USER "$SSH_DIR"
