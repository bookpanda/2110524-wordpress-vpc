#!/bin/bash
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress"
mkdir -p ~/.ssh
echo "$SSH_KEY" | sudo tee -a /home/ubuntu/.ssh/authorized_keys > /dev/null

echo "SSH key added to instance."

# make them available to other processes (child processes) that are spawned by the current shell
export DB_NAME="${DB_NAME}"
export DB_USER="${DB_USER}"
export DB_PASS="${DB_PASS}"
export DB_HOST="${DB_HOST}"
export DB_PREFIX="${DB_PREFIX}"
export WP_URL="${WP_URL}"
export WP_ADMIN_USER="${WP_ADMIN_USER}"
export WP_ADMIN_PASS="${WP_ADMIN_PASS}"
export WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"
export WP_TITLE="${WP_TITLE}"
export REGION="${REGION}"
export BUCKET_NAME="${BUCKET_NAME}"

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y php8.3 php8.3-mysql php8.3-cli php8.3-fpm php8.3-mbstring php8.3-xml
# needed for WP Offload Media Lite plugin
sudo apt install -y php8.3-curl php8.3-gd php8.3-imagick
sudo apt install -y apache2 unzip libapache2-mod-php8.3 software-properties-common curl

# MariaDB 10.11
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.11"
sudo apt-get update -y
sudo apt-get install -y mariadb-server

cd /var/www/html
sudo rm -rf *
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* .
sudo rm -rf wordpress latest.zip

sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 777 /var/www/html

sudo systemctl restart apache2

sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# /wp-admin/setup-config.php
sudo -u www-data -- wp config create --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASS} --dbhost=${DB_HOST} --dbprefix=${DB_PREFIX} --allow-root

# /wp-admin/install.php (--url is dns of wordpress)
sudo -u www-data -- wp core install --url=${WP_URL} \
--admin_user=${WP_ADMIN_USER} \
--admin_password=${WP_ADMIN_PASS} \
--admin_email=${WP_ADMIN_EMAIL} \
--title="${WP_TITLE}" --skip-email --allow-root

echo "Wordpress setup complete!"

echo "Setting up WP Offload Media Lite plugin..."

sudo -u www-data -- wp plugin install amazon-s3-and-cloudfront --activate --allow-root
sudo -u www-data -- wp option update amazon_s3_options "{\"bucket\": \"$BUCKET_NAME\", \"region\": \"$REGION\"}" --allow-root

WP_CONFIG="/var/www/html/wp-config.php"
sed -i "/define( 'DB_COLLATE', '' );/a \\
define( 'AS3CF_SETTINGS', serialize( array( \\
    'provider' => 'aws', \\
    'use-server-roles' => true, \\
    'bucket' => \"$BUCKET_NAME\", \\
    'region' => \"$REGION\", \\
    'copy-to-s3' => true, \\
    'enable-object-prefix' => true, \\
    'object-prefix' => 'wp-content/uploads/', \\
    'use-yearmonth-folders' => true, \\
    'object-versioning' => true, \\
    'delivery-provider' => 'storage', \\
    'serve-from-s3' => true, \\
    'enable-signed-urls' => false, \\
    'force-https' => false, \\
    'remove-local-file' => false, \\
) ) );" "$WP_CONFIG"

echo "WP Offload Media Lite plugin setup complete!"
