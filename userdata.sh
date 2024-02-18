#!/bin/bash

# Define parameters
DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)
WP_PATH="/var/www/html"

# update system
apt-get update && apt-get upgrade -y

# Install required packages
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql unzip

# Secure MySQL installation, same as mysql_secure_installation
myql --user=root << EOF
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# Create the WordPress database and user
sudo mysql -e "CREATE DATABASE $DB_NAME;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download and set up WordPress
sudo rm -rf /var/www/html/*
sudo wget -qO- https://wordpress.org/latest.tar.gz | sudo tar xvz -C /var/www/html/
sudo mv /var/www/html/wordpress/* /var/www/html/
sudo rm -rf /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/wordpress/ -type d -exec chmod 750 {} \;
sudo find /var/www/wordpress/ -type f -exec chmod 640 {} \;

# Configure WordPress
sudo cp $WP_PATH/wp-config-sample.php $WP_PATH/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/g" $WP_PATH/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" $WP_PATH/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/g" $WP_PATH/wp-config.php

# enable mod rewrite
a2enmod rewrite

# Enable and restart Apache
sudo systemctl enable apache2
sudo systemctl restart apache2
