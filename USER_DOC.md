# User Documentation

## 1. Overview

This document explains how to start, stop, access, and perform basic checks on the Inception infrastructure.

The infrastructure contains:

* NGINX for HTTPS access.
* WordPress with PHP-FPM for website functionality.
* MariaDB for database storage.

## 2. Starting the infrastructure

Navigate to the project root directory.

Start and build the services using:

```bash
make
```

If your Makefile uses a different target, use the target defined in the project.

To check the service status:

```bash
docker compose ps
```

All required services should be running.

## 3. Accessing the website

Open a browser and visit:

https://YOUR_LOGIN.42.fr

Replace `YOUR_LOGIN` with the configured 42 login.

The website should display the configured WordPress site rather than the initial WordPress installation screen.

HTTPS is provided by NGINX using a TLS certificate. A browser warning may appear if the certificate is self-signed.

HTTP access through port 80 is not intended to be available.

## 4. Accessing the WordPress administration panel

Visit:

https://YOUR_LOGIN.42.fr/wp-admin

Sign in using the WordPress administrator credentials configured during setup.

From the dashboard, an authorized administrator can:

* Create and edit pages.
* Create and edit posts.
* Manage comments.
* Manage users.
* Change themes and plugins where permitted.

Keep administrator credentials private.

## 5. Managing credentials

Database passwords and other sensitive values must not be committed to the Git repository.

When Docker secrets are used, the database service reads its passwords from the configured secret files mounted under `/run/secrets/`.

For example:

```text
/run/secrets/db_root_password
/run/secrets/db_password
```

The actual secret source paths are defined by the Docker Compose configuration.

To change a password, update the appropriate secret and follow the project's documented database password rotation procedure. Changing a secret file alone may not change an existing database account password.

Never publish passwords in documentation, source code, screenshots, or Git history.

## 6. Basic service checks

Check running containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

Check Docker networks:

```bash
docker network ls
```

Check Docker volumes:

```bash
docker volume ls
```

If a service fails to start, inspect its logs before attempting to rebuild it.

## 7. Stopping the infrastructure

Stop the services using:

```bash
make down
```

Alternatively, use:

```bash
docker compose down
```

This stops and removes the Compose containers and network created for the project. Named volumes normally remain unless explicitly removed.

**Do not remove persistent volumes** if you want to keep the WordPress website and MariaDB database.

Avoid commands such as:

```bash
docker compose down -v
```

unless you intentionally want to remove the Compose-managed volumes and understand the data-loss consequences.

## 8. Data persistence

WordPress files and MariaDB database files are stored in persistent Docker volumes.

This allows the data to survive ordinary container recreation and service restarts.

After a system reboot, start the infrastructure again:

```bash
make
```

Verify that the website and its previous content are still available.

## 9. Troubleshooting

### Website unavailable

Check:

```bash
docker compose ps
docker compose logs nginx
```

Verify that port 443 is available and the hostname resolves correctly.

### WordPress cannot connect to MariaDB

Check:

```bash
docker compose logs wordpress
docker compose logs mariadb
```

Verify the database hostname, database name, username, password, network, and secret mounts.

### Website shows an installation page

Verify the WordPress configuration, database connection, database contents, and persistent volumes.

### Service fails after a configuration change

Review the relevant service logs and configuration files, then rebuild and restart the affected infrastructure using the project's documented commands.
