#!/bin/bash

set -e

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

echo "Starting MariaDB..."

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql "$DATADIR"

if [ ! -d "$DATADIR/mysql" ]; then
echo "Initializing MariaDB database..."

```
mariadb-install-db \
    --user=mysql \
    --datadir="$DATADIR" \
    --skip-test-db

echo "Starting temporary MariaDB server..."

mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --skip-networking \
    --socket="$SOCKET" &

TEMP_PID=$!

echo "Waiting for MariaDB..."

until mariadb-admin \
    --socket="$SOCKET" \
    ping --silent
do
    sleep 1
done

echo "MariaDB is ready."

mariadb \
    --socket="$SOCKET" \
    -u root <<EOF
```

CREATE DATABASE IF NOT EXISTS `${MYSQL_DATABASE}`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON `${MYSQL_DATABASE}`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

FLUSH PRIVILEGES;

EOF

```
echo "Database and user created."

echo "Stopping temporary MariaDB..."

mariadb-admin \
    --socket="$SOCKET" \
    -u root \
    -p"${DB_ROOT_PASSWORD}" \
    shutdown

wait "$TEMP_PID"

echo "MariaDB initialization complete."
```

else
echo "MariaDB already initialized."
fi

echo "Starting MariaDB server..."

exec mysqld 
--user=mysql 
--datadir="$DATADIR" 
--console
