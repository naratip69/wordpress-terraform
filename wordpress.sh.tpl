#!/bin/bash

# Update package lists and upgrade installed packages
sudo apt update -y
sudo apt upgrade -y

# Install necessary packages
sudo apt install -y build-essential libxml2-dev libssl-dev libcurl4-openssl-dev \
libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libicu-dev libbz2-dev \
libmcrypt-dev libreadline-dev libmysqlclient-dev libxslt-dev libzip-dev wget apache2 \
libsqlite3-dev libonig-dev pkg-config php-fpm php-mysql

# Download PHP 8.3 source code
wget https://www.php.net/distributions/php-8.3.0.tar.bz2 || { echo "PHP download failed"; exit 1; }
tar -xjf php-8.3.0.tar.bz2
cd php-8.3.0

# Configure PHP build options
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc \
  --enable-bcmath --enable-fpm --with-openssl --with-curl --enable-mbstring \
  --enable-soap --enable-sockets --with-xsl --with-bz2 --with-mysqli --with-pdo-mysql

# Compile PHP
make -j$(nproc)

# Install PHP
sudo make install

# Set up PHP configuration
sudo cp php.ini-production /usr/local/php/lib/php.ini
sudo cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf

# Enable and start PHP-FPM
sudo systemctl enable php-fpm
sudo systemctl start php-fpm

# Configure Apache to use PHP 8.3 with PHP-FPM
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php-fpm
sudo systemctl restart apache2

# Install Apache PHP module (useful for fallback if needed)
sudo apt install -y libapache2-mod-php
sudo apt-get install -y php-xml php-curl php-gd

# Enable Apache to start on boot
sudo systemctl enable apache2
sudo systemctl start apache2

# Update system PATH to include PHP binary
echo 'export PATH=$PATH:/usr/local/php/bin' | sudo tee /etc/profile.d/php.sh
source /etc/profile.d/php.sh

# Download and install WordPress
cd /var/www/html
sudo rm -f index.html  # Remove default Apache page
sudo wget https://wordpress.org/latest.tar.gz || { echo "WordPress download failed"; exit 1; }
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

# Ensure correct permissions for wp-config.php
sudo chown www-data:www-data /var/www/html/wp-config.php

# Install WP-CLI to automate WordPress setup
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar || { echo "WP-CLI download failed"; exit 1; }
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Create the WordPress admin user
cd /var/www/html/
sudo -u www-data wp core install --url="http://${wordpress_endpoint}" --title="My WordPress Site" --admin_user="${admin_user}" --admin_password="${admin_pass}" --admin_email="${admin_email}"

sudo -u www-data wp user create ${admin_user} ${admin_email} --role=administrator --user_pass=${admin_pass}

# Install WP Offload Media Plugin
sudo -u www-data wp plugin install amazon-s3-and-cloudfront --activate

# Path to wp-config.php
WP_CONFIG="/var/www/html/wp-config.php"

# Define the configuration block
CONFIG_BLOCK=$(cat <<'EOF'

define( 'AS3CF_SETTINGS', serialize( array(

    'provider' => 'aws',
    'use-server-roles' => true,
    'bucket' => '${bucket_name}',
    'region' => '${region}',
    'copy-to-s3' => true,
    'enable-object-prefix' => true,
    'object-prefix' => 'wp-content/uploads/',
    'use-yearmonth-folders' => true,
    'object-versioning' => true,
    'delivery-provider' => 'storage',
    'serve-from-s3' => true,
    'enable-delivery-domain' => false,
    'delivery-domain' => 'cdn.example.com',
    'enable-signed-urls' => false,
    'force-https' => false,
    'remove-local-file' => false,
) ) );

define( 'AS3CF_ASSETS_PULL_SETTINGS', serialize( array(
    'rewrite-urls' => false,
    'force-https' => false,
) ) );

EOF
)
# Use sed to insert the config between the comments
sudo sed -i "/\/\* Add any custom values between this line and the \"stop editing\" line. \*\//r /dev/stdin" "$WP_CONFIG" <<< "$CONFIG_BLOCK"
# Restart Apache to apply the changes
sudo systemctl restart apache2

# SSH Key Setup for ubuntu user
USER="ubuntu"

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
