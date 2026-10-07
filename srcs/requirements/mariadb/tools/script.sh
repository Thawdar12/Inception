#!/bin/bash

service mariadb start

mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY "$(cat /run/secrets/db_root_password)";
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY "$(cat /run/secrets/db_password)";
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
EOF

service mariadb stop

exec mariadbd --user=mysql