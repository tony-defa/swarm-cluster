# MantisBT

Mantis Bug Tracker is a free and open source web-based bug tracking system.

### `mantisbt.yml`
MantisBT application stack with MariaDB database and automated backup service.

## Prerequisites

### Storage
Requires three dedicated storage volumes:
- Application configuration storage
- Database persistent storage
- Database backup storage

### Service dependencies
- Traefik proxy stack must be deployed first

### Create docker secrets
Create the following docker secrets:

- `mantisbt_db_database`: MantisBT database name
- `mantisbt_db_user`: Database username
- `mantisbt_db_password`: Database user password
- `mantisbt_db_root_password`: Database root password

Create secrets using:
```bash
printf "secret_value" | docker secret create secret_name -
```

### Create network
```bash
docker network create -d overlay mantisbt_internal
```

## Other notes

Database backups run automatically every 24 hours (configurable via `BACKUP_FREQUENCY`). Backups are retained for 7 days by default.
All services include health checks for proper monitoring and automatic recovery.

## Deployment

```bash
# Copy environment file
cp example.env .env

# Edit configuration
vi .env

# Deploy stack
../../deploy-stack.sh mantisbt
```
