*This project has been created as part of the 42 curriculum by tswe-zin.*

# Inception

## Description

Inception is a system administration project that introduces Docker and Docker Compose by building a small infrastructure composed of multiple services.

The infrastructure consists of three main services:

* **NGINX:** Web server and reverse proxy configured to use TLS.
* **WordPress:** Content management system running with PHP-FPM.
* **MariaDB:** Relational database used by WordPress to store website data.

Each service is built from its own Dockerfile using an appropriate Alpine or Debian base image. The services communicate through a dedicated Docker network.

### Architecture

```text
                 User's Browser
                       |
                    HTTPS :443
                       |
                    NGINX
                       |
                    PHP-FPM
                   WordPress
                       |
                    MariaDB
                       |
                 Persistent Volumes
```

Only NGINX is exposed to the host. WordPress and MariaDB communicate through the internal Docker network.

### Main objectives

* Learn containerization with Docker.
* Orchestrate multiple services using Docker Compose.
* Build custom Docker images.
* Configure HTTPS using TLS.
* Understand Docker networks and persistent volumes.
* Manage credentials securely.
* Maintain persistent website and database data.

## Instructions

### Prerequisites

* Docker Engine
* Docker Compose plugin
* GNU Make
* A Linux virtual machine or the environment required by the project
* Appropriate permissions to run Docker commands

### Configuration

1. Clone the repository.
2. Create the required configuration and secret files locally.
3. Configure the environment variables required by the services.
4. Generate or provide the TLS certificate and private key.
5. Ensure that sensitive files are excluded from Git.

Example local configuration:

```text
srcs/.env
secrets/db_root_password
secrets/db_password
```

The exact file paths must match the Docker Compose configuration.

Add local secret files to `.gitignore`. Never commit actual passwords, API keys, tokens, or private keys.

### Start the infrastructure

From the project root, run:

```bash
make
```

Alternatively, if supported by the project:

```bash
docker compose up --build -d
```

### Stop the infrastructure

```bash
make down
```

Alternatively:

```bash
docker compose down
```

### Check the services

```bash
docker compose ps
docker compose logs
docker network ls
docker volume ls
```

### Access the website

Open the following address in a browser, replacing `YOUR_LOGIN` with the required login:

https://YOUR_LOGIN.42.fr

The WordPress administration panel is available at:

https://YOUR_LOGIN.42.fr/wp-admin

The website is configured for HTTPS access on port 443.

## Resources

### Documentation

* Docker documentation: https://docs.docker.com/
* Docker Compose documentation: https://docs.docker.com/compose/
* NGINX documentation: https://nginx.org/en/docs/
* WordPress documentation: https://wordpress.org/documentation/
* MariaDB documentation: https://mariadb.com/docs/
* PHP documentation: https://www.php.net/docs.php
* OpenSSL documentation: https://docs.openssl.org/

### AI usage

AI tools were used as supplementary learning and development aids during this project. They helped clarify Docker and Docker Compose concepts, explain service configuration, troubleshoot shell scripts, discuss secret management, and improve the documentation.

AI-generated suggestions were reviewed and adapted to the project's requirements. The final configuration, implementation, testing, and understanding of the infrastructure remain the responsibility of the student.

### Project author

42 login: tswe-zin
