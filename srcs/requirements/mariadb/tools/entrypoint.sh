#!/bin/bash

set -e

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

# Allow only simple database and username identifiers.
if [[ ! "$MYSQL_DATABASE" =~ ^[A-Za-z0-9_]+$ ]] ||
   [[ ! "$MYSQL_USER" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "ERROR: Invalid database name or username."
    exit 1
fi

# Escape single quotes in passwords for SQL.
sql_escape() {
    printf '%s' "$1" | sed "s/'/''/g"
}

DB_ROOT_PASSWORD_SQL="$(sql_escape "$DB_ROOT_PASSWORD")"
DB_PASSWORD_SQL="$(sql_escape "$DB_PASSWORD")"

echo "Starting MariaDB setup..."

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATADIR"

# Initialize only when the data directory is new.
if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB database..."
    mariadb-install-db \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-test-db
fi

# Start a temporary local-only server.
echo "Starting temporary MariaDB server..."

mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --skip-networking \
    --socket="$SOCKET" \
    --pid-file=/run/mysqld/mysqld.pid &

TEMP_PID=$!

# Stop the script if initialization fails.
cleanup() {
    if kill -0 "$TEMP_PID" 2>/dev/null; then
        kill "$TEMP_PID" 2>/dev/null || true
        wait "$TEMP_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo "Waiting for temporary MariaDB..."

until mariadb-admin --socket="$SOCKET" ping --silent >/dev/null 2>&1; do
    if ! kill -0 "$TEMP_PID" 2>/dev/null; then
        echo "ERROR: Temporary MariaDB server exited."
        exit 1
    fi
    sleep 1
done

# Support either local socket authentication or password authentication.
if mariadb --socket="$SOCKET" -u root -e "SELECT 1;" >/dev/null 2>&1; then
    ROOT_ARGS=(-u root)
elif mariadb --socket="$SOCKET" -u root \
    -p"${DB_ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; then
    ROOT_ARGS=(-u root "-p${DB_ROOT_PASSWORD}")
else
    echo "ERROR: Cannot authenticate as MariaDB root."
    exit 1
fi

echo "Ensuring WordPress database and user exist..."

mariadb --socket="$SOCKET" "${ROOT_ARGS[@]}" <<SQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%'
    IDENTIFIED BY '${DB_PASSWORD_SQL}';

ALTER USER '${MYSQL_USER}'@'%'
    IDENTIFIED BY '${DB_PASSWORD_SQL}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.*
    TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost'
    IDENTIFIED BY '${DB_ROOT_PASSWORD_SQL}';

FLUSH PRIVILEGES;
SQL

echo "Database and user are ready."

# Use the configured root password to shut down the temporary server.
mariadb-admin \
    --socket="$SOCKET" \
    "${ROOT_ARGS[@]}" \
    shutdown

wait "$TEMP_PID"
trap - EXIT

echo "Starting MariaDB normally..."

exec mysqld \
    --user=mysql \
    --datadir="$DATADIR" \
    --bind-address=0.0.0.0 \
    --console
