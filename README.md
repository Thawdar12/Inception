*This project has been created as part of the 42 curriculum by tswe-zin.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. Its goal is to build a small, secure, multi-service infrastructure using Docker and Docker Compose inside a virtual machine.

The infrastructure consists of three main services:

- **NGINX:** A web server and reverse proxy that provides HTTPS access using TLSv1.2 or TLSv1.3.
- **WordPress:** A content management system running with PHP-FPM.
- **MariaDB:** A relational database used by WordPress to store website data.

Each service has its own Dockerfile and custom-built Docker image based on Debian or Alpine. The services run in separate containers and communicate through a dedicated Docker network.

Persistent Docker volumes are used to preserve the WordPress website files and MariaDB database data.

### Architecture

```text
                 User's Browser
                       |
                    HTTPS :443
                       |
                    NGINX
                       |
                    PHP-FPM
                       |
                   WordPress
                       |
                    MariaDB
                       |
                Persistent Volumes
```

Only NGINX is exposed to the host on port 443. WordPress and MariaDB communicate through the Docker network and are not directly exposed to the host.

### Main Objectives

- Learn containerization with Docker.
- Orchestrate multiple services using Docker Compose.
- Build custom Docker images using individual Dockerfiles.
- Configure NGINX with HTTPS and TLS.
- Connect services through a dedicated Docker network.
- Use persistent volumes to preserve application and database data.
- Manage configuration and credentials using environment variables and secrets.
- Understand container lifecycle management, service dependencies, and restart policies.

### Project Structure

```text
.
├── Makefile
├── README.md
├── secrets/
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            └── tools/
```

The `Makefile` provides commands for building, starting, stopping, and cleaning up the infrastructure.

- `srcs/docker-compose.yml` defines the services, networks, volumes, and secrets.
- `srcs/.env` stores configuration values used by Docker Compose.
- `srcs/requirements/` contains the Dockerfiles and configuration files for each service.
- `secrets/` contains sensitive credentials used during service initialization.

The exact contents may evolve as the project is developed.

### Main Design Choices

**Custom Docker images**

Each service is built from its own Dockerfile instead of using a prebuilt application image. Debian or Alpine is used as the base image, and each service installs and configures only the software it needs.

**Separate containers**

NGINX, WordPress with PHP-FPM, and MariaDB run in dedicated containers. This separation makes the infrastructure easier to maintain, test, and troubleshoot.

**Dedicated Docker network**

The services communicate over a user-defined Docker network. This allows containers to reach one another by service name without relying on host networking.

**Persistent storage**

Two persistent volumes are used: one for MariaDB database data and another for WordPress website files. The data is stored under `/home/tswe-zin/data` on the host, as required by the project.

**HTTPS entry point**

NGINX is the only public entry point and listens on port 443 using TLSv1.2 or TLSv1.3. WordPress and MariaDB are not published directly to the host.

### Technical Comparisons

#### 1. Virtual Machines vs. Docker

A virtual machine runs a complete guest operating system on virtualized hardware. Docker containers isolate applications while sharing the host machine's kernel.

| Virtual Machines | Docker |
|---|---|
| Each VM runs its own operating system kernel. | Containers share the host kernel. |
| Usually consumes more resources. | Usually has lower resource overhead. |
| Provides isolation at the VM level. | Provides process and resource isolation. |
| Useful for running different operating systems. | Useful for packaging and running individual services. |

In this project, Docker is used to run the services separately inside a virtual machine, as required by the subject.

#### 2. Secrets vs. Environment Variables

Environment variables provide configuration values to processes. They are convenient for settings such as domain names and database names, but passwords passed as environment variables may be exposed through container inspection or process environments.

Docker secrets provide a mechanism for making sensitive values available to services, commonly as files mounted inside the container.

| Environment Variables | Secrets |
|---|---|
| Suitable for general application configuration. | Intended for sensitive values such as passwords. |
| Convenient to configure through a `.env` file. | Can be mounted as files for applications to read. |
| May be exposed through inspection or diagnostics. | Can reduce accidental exposure when handled correctly. |

This project uses environment variables for configuration and secrets for sensitive credentials where supported by the chosen Docker Compose setup. A `.env` file is not automatically a secure secret store, and secret files must not be committed to Git.

#### 3. Docker Network vs. Host Network

A Docker network provides communication between containers through an isolated network. A host network shares the host's network namespace with the container.

| Docker Network | Host Network |
|---|---|
| Containers communicate over a Docker-managed network. | The container uses the host network namespace. |
| Services can be discovered by service name on a user-defined network. | Network isolation is reduced. |
| Port publishing can control which container ports are exposed. | Port publishing is generally unnecessary and ignored. |

This project uses a dedicated Docker network to connect NGINX, WordPress, and MariaDB. Host networking is not used.

#### 4. Docker Volumes vs. Bind Mounts

Both volumes and bind mounts allow data to persist outside a container's writable layer.

| Docker Volumes | Bind Mounts |
|---|---|
| Managed by Docker. | Use a specified host filesystem path. |
| Useful for persistent application data. | Useful for sharing specific host files or directories with containers. |
| Docker manages their storage location. | The host path is explicitly defined. |

This project uses persistent storage for the database and WordPress files, with the host data located under `/home/tswe-zin/data`. The Compose configuration determines whether each persistent mount is implemented as a named volume or a bind mount.

## Instructions

### Prerequisites

- A virtual machine running Linux.
- Docker Engine.
- Docker Compose compatible with the installed Docker version.
- GNU Make.
- Git.
- A user account with permission to run Docker commands.

### Configuration

1. Clone the repository and enter the project directory.
2. Create the required configuration and secret files.
3. Configure the environment variables in `srcs/.env`.
4. Configure the service Dockerfiles and their supporting configuration files.
5. Provide the required TLS certificate and private key for NGINX.
6. Ensure the required host data directories exist and have appropriate permissions.
7. Exclude sensitive files, passwords, private keys, and local-only configuration from version control.

The environment file should be located at:

```text
srcs/.env
```

Secret files should use the paths referenced by the Compose configuration. Keep real credentials out of the README, Dockerfiles, and Git repository.

### Build and Start the Infrastructure

From the repository root, run:

```bash
make build
make
```

The `build` target builds the service images. The default `make` target starts the infrastructure in detached mode, according to the Makefile.

Alternatively, with a compatible Compose installation:

```bash
docker-compose -f srcs/docker-compose.yml up --build -d
```

### Check the Services

Check the container status:

```bash
docker-compose -f srcs/docker-compose.yml ps
```

View service logs:

```bash
docker-compose -f srcs/docker-compose.yml logs
```

List Docker networks and volumes:

```bash
docker network ls
docker volume ls
```

### Stop the Infrastructure

Run:

```bash
make down
```

This stops and removes the Compose-managed containers and network, but normally preserves named volumes.

To remove the volumes as well, use the project's `make clean` target only when you intend to delete persistent data.

### Access the Website

After the services are configured and running, add the required domain mapping to the VM's hosts file if local DNS does not already resolve it:

```text
<VM_IP_ADDRESS> tswe-zin.42.fr
```

Then open:

- Website: `https://tswe-zin.42.fr`
- WordPress administration: `https://tswe-zin.42.fr/wp-admin`

Replace the example IP address with your virtual machine's IP address. A browser certificate warning may appear if the TLS certificate is self-signed.

The website will only be available once WordPress has been configured, the database connection works, and NGINX is correctly configured.

## Resources

### Official Documentation

- Docker documentation: https://docs.docker.com/
- Docker Engine: https://docs.docker.com/engine/
- Docker Compose: https://docs.docker.com/compose/
- Dockerfile reference: https://docs.docker.com/reference/dockerfile/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/docs/
- PHP documentation: https://www.php.net/docs.php
- PHP-FPM configuration: https://www.php.net/manual/en/install.fpm.php
- OpenSSL documentation: https://docs.openssl.org/

### AI Usage

AI tools were used as supplementary learning and development aids throughout the project.

They helped with:

- Understanding Docker images, containers, Dockerfiles, volumes, networks, and Docker Compose.
- Learning how NGINX, PHP-FPM, WordPress, and MariaDB communicate.
- Understanding environment variables, secrets, and persistent storage.
- Troubleshooting commands, configuration files, and container behavior.
- Reviewing and improving the README documentation.

AI-generated suggestions were reviewed and adapted to the project's requirements. The student is responsible for understanding, implementing, testing, and validating the final configuration and for ensuring that the project complies with the 42 Inception subject.

### Author

- **42 login:** `tswe-zin`

.gitignore
/srcs/.env
/secrets
