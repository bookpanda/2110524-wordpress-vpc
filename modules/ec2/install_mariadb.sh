#!/bin/bash
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODaHqtrCOBpfD+meWggDG5gFEqnNDtpxnqQ7xWIfXfL cloud-wordpress"
mkdir -p ~/.ssh
echo "$SSH_KEY" | sudo tee -a /home/ubuntu/.ssh/authorized_keys > /dev/null

echo "SSH key added to instance."

# make them available to other processes (child processes) that are spawned by the current shell
export DB_NAME="${DB_NAME}"
export DB_USER="${DB_USER}"
export DB_PASS="${DB_PASS}"

sudo apt-get update -y
sudo apt-get install -y software-properties-common curl

# MariaDB 10.11
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.11"

sudo apt-get update -y
sudo apt-get install -y mariadb-server mariadb-client

sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation (automated using 'expect')
sudo apt-get install -y expect
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn sudo mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\n\"
expect \"Switch to unix_socket authentication\"
send \"n\n\"
expect \"Set root password?\"
send \"Y\n\"
expect \"New password:\"
send \"root_password\n\"
expect \"Re-enter new password:\"
send \"root_password\n\"
expect \"Remove anonymous users?\"
send \"Y\n\"
expect \"Disallow root login remotely?\"
send \"N\n\"
expect \"Remove test database and access to it?\"
send \"Y\n\"
expect \"Reload privilege tables now?\"
send \"Y\n\"
expect eof
")
echo "$SECURE_MYSQL"

sudo mysql -u root -proot_password <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

CONF_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"
sudo sed -i 's/^bind-address\s*=.*$/bind-address = 0.0.0.0/' $CONF_FILE

sudo systemctl restart mariadb
sudo systemctl status mariadb

echo "MariaDB setup complete!"