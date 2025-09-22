# n8n

n8n is a fair-code workflow automation platform.

### `n8n.yml`
Contains the n8n service, a PostgreSQL database service, and a backup service.

## Prerequisites
### Storage
A centralized storage solution is required for persistent data and backups.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets for database and basic authentication credentials:

- `n8n_db_user`: The username for the PostgreSQL database
- `n8n_db_password`: The password for the PostgreSQL database
- `n8n_basic_auth_user`: The username for n8n basic authentication
- `n8n_basic_auth_password`: The password for n8n basic authentication

### Create network
No network needs to be created.

## Other notes
### Backup
The backup service securely backs up the n8n data and the PostgreSQL database. The backup interval and retention are defined in the environment variables `BACKUP_FREQUENCY` and `RETENTION_DAYS`.