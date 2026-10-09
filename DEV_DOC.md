# Developer Documentation

## 1. Overview

This document describes the development environment, project structure, Docker Compose workflow, networking, storage, secrets, and troubleshooting procedures for Inception.

The infrastructure is composed of three custom-built services:

* NGINX
* WordPress with PHP-FPM
* MariaDB

Each service has its own Dockerfile and a dedicated responsibility.

## 2. Prerequisites

Install and configure:

* Docker Engine
* Docker Compose plugin
* GNU Make
* A compatible Linux environment or the VM required by the subject

Verify the installation:

```bash
docker --version
docker compose version
make --version
```

## 3. Project structure

A typical project structure is:

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── .gitignore
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        └── mariadb/
            ├── Dockerfile
            └── tools/
```

A local `secrets/` directory may also be used, depending on the configuration.

The exact directory layout should follow the project subject and the actual repository.

### Responsibilities

* `Makefile`: shortcuts for common build, start, stop, and cleanup operations.
* `docker-compose.yml`: service definitions, networks, volumes, ports, environment variables, and secrets.
* NGINX Dockerfile and configuration: web server installation and TLS configuration.
* WordPress Dockerfile and scripts: PHP-FPM, WordPress setup, and application configuration.
* MariaDB Dockerfile and scripts: database installation and initialization.
* `.env`: local non-secret configuration and any sensitive values explicitly managed this way.
* `secrets/`: local secret source files when Docker secrets are used.

## 4. Environment variables and secrets

Configuration values can be supplied through environment variables.

For example, the project may use:

```text
MYSQL_DATABASE
MYSQL_USER
```

The exact variable names must match the implementation.

Sensitive values such as database passwords should be kept out of source control. When using Docker secrets, services can read the configured secret files from `/run/secrets/`.

For example:

```bash
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"
```

The secret names must match the Compose configuration.

Add local secret files to `.gitignore`. Example:

```gitignore
/srcs/.env
/secrets/
```

If the actual `.env` file is located elsewhere, update the ignore rule accordingly.

A `.gitignore` rule does not untrack files that have already been committed. Check tracked files and Git history before submission. If credentials have been exposed, rotate them and remove the exposure appropriately.

## 5. Building and running

From the project root, use the project's Makefile:

```bash
make
```

Inspect the Makefile to confirm the actual targets and commands.

A typical Compose build and start command is:

```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

The path above is an example and should be adjusted if the Compose file is elsewhere.

Check service status:

```bash
docker compose ps
```

Follow logs:

```bash
docker compose logs -f
```

To view an individual service:

```bash
docker compose logs -f nginx
docker compose logs -f wordpress
docker compose logs -f mariadb
```

Stop the infrastructure:

```bash
docker compose down
```

Use the same Compose file and project name consistently when managing the stack.

## 6. Dockerfiles and images

Each service must have its own non-empty Dockerfile.

The project requires custom images built from an appropriate stable Alpine or Debian base image as specified by the subject.

For example, a Dockerfile starts with a permitted base image declaration:

```dockerfile
FROM debian:<required-version>
```

Replace the placeholder with the exact permitted version.

Build the images through Docker Compose:

```bash
docker compose build
docker compose up -d
```

Verify the available images:

```bash
docker images
```

Image names should correspond to the service names, in accordance with the project's Compose configuration.

Do not substitute ready-made application images for the custom images required by the subject.

## 7. Docker networking

The services communicate over a dedicated Docker network.

NGINX receives incoming HTTPS traffic and forwards PHP requests to WordPress/PHP-FPM. WordPress connects to MariaDB using its Compose service name and the database port.

For example:

```text
NGINX → WordPress/PHP-FPM → MariaDB:3306
```

MariaDB should not be published to the host unless explicitly required.

Inspect networks:

```bash
docker network ls
docker network inspect <network-name>
```

Service names provide internal DNS resolution within a shared Docker network.

## 8. NGINX and TLS

NGINX is the public entry point to the infrastructure.

The host should expose port 443 only:

```yaml
ports:
  - "443:443"
```

The exact port mapping must match the actual configuration.

TLS must support at least TLS 1.2 or TLS 1.3. Certificate and private-key paths must match the NGINX configuration.

Test the HTTPS connection:

```bash
openssl s_client -connect YOUR_LOGIN.42.fr:443 -tls1_2
```

Alternatively, test TLS 1.3 where supported:

```bash
openssl s_client -connect YOUR_LOGIN.42.fr:443 -tls1_3
```

A self-signed certificate may trigger a browser warning.

## 9. WordPress and PHP-FPM

The WordPress service runs PHP-FPM and the WordPress application. NGINX is maintained in a separate container.

WordPress requires the correct database host, database name, username, and password.

Its persistent volume stores the relevant WordPress files and content required by the implementation.

Check the service:

```bash
docker compose logs wordpress
```

Verify that PHP-FPM is running and that NGINX can communicate with it over the configured internal network.

## 10. MariaDB

MariaDB stores WordPress database content, including posts, pages, comments, users, and configuration.

The initialization script should:

1. Initialize the database directory if necessary.
2. Start a temporary server when initialization is required.
3. Create the database and application user.
4. Configure database privileges and root authentication.
5. Shut down the temporary server cleanly.
6. Start MariaDB as the main container process.

The initialization must be idempotent enough to avoid recreating the database or resetting credentials on every restart.

Check the logs:

```bash
docker compose logs mariadb
```

Connect to the database from the MariaDB container using the credentials configured for the project.

For example:

```bash
docker compose exec mariadb mariadb -u root -p
```

Then inspect the database:

```sql
SHOW DATABASES;
USE your_database;
SHOW TABLES;
```

Replace `your_database` with the actual configured database name.

## 11. Volumes and persistence

Persistent volumes preserve application and database data beyond the lifecycle of individual containers.

Inspect volumes:

```bash
docker volume ls
docker volume inspect <volume-name>
```

For this project, verify that the host-backed storage is configured to meet the required `/home/YOUR_LOGIN/data/` path convention.

The actual bind-mount or volume configuration must be checked against the subject requirements.

Avoid deleting persistent storage during normal development. Removing containers is not the same as removing volumes.

## 12. Makefile

The Makefile provides convenient commands for managing the infrastructure.

Check the available targets:

```bash
make
```

Common targets may include:

```bash
make
make down
make clean
make re
```

These target names are examples; use only the targets implemented by the repository.

Before running cleanup commands, inspect their definitions to understand whether they remove containers, images, or persistent volumes.

## 13. Rebuilding after a configuration change

After modifying a Dockerfile or service configuration, rebuild and restart the project.

For example:

```bash
docker compose up --build -d
docker compose ps
docker compose logs
```

For a port change, update the Compose port mapping and any related service configuration, then rebuild or recreate the affected service as needed.

For example, mapping host port 8443 to container port 443 would allow HTTPS access through:

```text
https://YOUR_LOGIN.42.fr:8443
```

Ensure the selected host port is available.

## 14. Troubleshooting

### Containers are not running

```bash
docker compose ps
docker compose logs
```

### Network connectivity problems

```bash
docker network ls
docker network inspect <network-name>
```

Verify service names and that the required containers share a network.

### Database connection failures

Check MariaDB logs, WordPress configuration, credentials, secret mounts, and service-name resolution.

### TLS failures

Verify certificate paths, private-key permissions, NGINX configuration, port mappings, and supported TLS versions.

### Persistence problems

Inspect the volume configuration and confirm that the application is writing data to the mounted persistent directory.

### Configuration validation

Before restarting, validate the Compose configuration:

```bash
docker compose config
```

Resolve configuration errors before rebuilding.

## 15. Final verification

Before submission, verify:

* All required services build from their own Dockerfiles.
* The Compose stack starts without errors.
* Only NGINX is exposed to the host on port 443.
* HTTPS works with TLS 1.2 or TLS 1.3.
* WordPress is installed and connected to MariaDB.
* The database contains WordPress tables.
* Both required persistent storage locations are correct.
* Data survives container recreation and VM reboot.
* Credentials are not committed to Git.
* The stack can be rebuilt after a configuration change.
