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

### Create network
No network needs to be created.

## Environment variables

The stack uses the following n8n environment variables, updated for compatibility with n8n v2.x:

| Variable | Purpose |
| -------- | ------- |
| `DB_TYPE` | Set to `postgresdb` (not `postgres`) |
| `DB_POSTGRESDB_HOST` | PostgreSQL host (uses `db` service name) |
| `DB_POSTGRESDB_DATABASE` | PostgreSQL database name |
| `DB_POSTGRESDB_USER_FILE` | Docker secret file for DB user |
| `DB_POSTGRESDB_PASSWORD_FILE` | Docker secret file for DB password |
| `N8N_EDITOR_BASE_URL` | Public URL for the n8n editor |
| `N8N_WEBHOOK_URL` | Base URL for webhooks (replaces deprecated `WEBHOOK_URL`) |
| `N8N_PROXY_HOPS` | Number of reverse proxies (default: `1`) |
| `N8N_ENCRYPTION_KEY` | Custom encryption key for credentials |
| `N8N_DIAGNOSTICS_ENABLED` | Enable/disable telemetry |
| `N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS` | Enforce secure file permissions |

## Other notes
### Backup
The backup service securely backs up the n8n data and the PostgreSQL database. The backup interval and retention are defined in the environment variables `BACKUP_FREQUENCY` and `RETENTION_DAYS`.