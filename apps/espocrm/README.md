# EspoCRM

EspoCRM is a fully-featured, open-source Customer Relationship Management (CRM) system written in PHP.  
This Docker stack runs EspoCRM with a MariaDB backend, exposes the web UI through Traefik, and keeps regular backups of the database and file system.

## `docker-stack.yml`
The stack file contains three services:

1. **web** – EspoCRM (nginx/Apache front-end)  
2. **db** – MariaDB database server  
3. **backup** – a background job that creates daily dumps of the database and the application files

All services share the same set of environment variables (`.env`), use bind mounts for persistence, and are connected to the `proxy_network` (created by Traefik) and a dedicated overlay network `espocrm_network`.

## Prerequisites

### Storage
A **centralized storage solution** (e.g. NAS, NFS, or bind mounts on the Docker host) is required to persist:

- Application files (`HOST_ESPOCRM_DATA`)
- MariaDB data (`HOST_ESPOCRM_DB`)
- Backup archives (`HOST_ESPOCRM_BACKUP`)

Ensure that the host directories exist and have the proper permissions (e.g. `chmod 777` or user-specific ownership matching the container user).

### Service dependencies
The stack depends on Traefik for routing and HTTPS termination.  
You must have the **system/traefik.yml** stack (or any other Traefik stack) running and exposing the `proxy_network` overlay network.

### Create pre-configured data folder
No pre-configured data folder is supplied with the stack.  
Create the three directories on the host:

```bash
mkdir -p /cluster/espocrm_data/db
mkdir -p /cluster/espocrm_data/data
mkdir -p /cluster/espocrm_data/backup