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
docker-compose -f srcs/docker-compose.yml ps
```

All required services should be running.

## 3. Accessing the website

Open a browser and visit:

https://tswe-zin.42.fr

The website should display the configured WordPress site rather than the initial WordPress installation screen.

HTTPS is provided by NGINX using a TLS certificate. A browser warning may appear if the certificate is self-signed.

HTTP access through port 80 is not intended to be available.

## 4. Accessing the WordPress administration panel

Visit:

https://tswe-zin.42.fr/wp-admin

Sign in using the WordPress administrator credentials configured during setup.

From the dashboard, an authorized administrator can:

* Create and edit pages.
* Create and edit posts.
* Manage comments.
* Manage users.
* Change themes and plugins where permitted.

Keep administrator credentials private.

## 5. Required Local Files

Before starting the project, create a `.env` file and a `secrets/` folder in the project directory.

- **`.env`**: Stores environment variables such as the domain name, database name, database username, and other required configuration values.
- **`secrets/`**: Stores sensitive credentials in separate files, such as database root passwords, database passwords, and WordPress user passwords.

Example project structure:

```text
.
├── .env
├── secrets/
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   └── wp_db_password.txt
└── srcs/
    └── docker-compose.yml
```

Make sure to replace example values with your own configuration and passwords. These files must remain local and must not be committed to the Git repository. Add `.env` and `secrets/` to `.gitignore`.

**Important:** Creating these files is not enough by itself. Ensure that your Docker Compose configuration references the correct paths and that your application scripts read the secrets where required.

## 6. Basic service checks

Check running containers:

```bash
docker-compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker-compose -f srcs/docker-compose.yml logs nginx
docker-compose -f srcs/docker-compose.yml logs wordpress
docker-compose -f srcs/docker-compose.yml logs mariadb
```

Check Docker networks:

```bash
docker network ls
docker network inspect srcs_inception 
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

This stops and removes the Compose containers and network created for the project. Named volumes normally remain unless explicitly removed.

**Do not remove persistent volumes** if you want to keep the WordPress website and MariaDB database.

Avoid commands such as:

```bash
make fclean
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
docker-compose -f srcs/docker-compose.yml ps
docker-compose -f srcs/docker-compose.yml logs nginx
```

Verify that port 443 is available and the hostname resolves correctly.

### WordPress cannot connect to MariaDB

Check:

```bash
docker-compose -f srcs/docker-compose.yml logs wordpress
docker-compose -f srcs/docker-compose.yml logs mariadb
```

Verify the database hostname, database name, username, password, network, and secret mounts.

### Website shows an installation page

Verify the WordPress configuration, database connection, database contents, and persistent volumes.

### Service fails after a configuration change

Review the relevant service logs and configuration files, then rebuild and restart the affected infrastructure using the project's documented commands.
