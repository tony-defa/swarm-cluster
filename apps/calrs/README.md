# CalRS

Fast, self-hostable scheduling platform. Like Cal.com, but written in Rust. CalRS connects to CalDAV calendars, defines bookable meeting types, and shares a link for scheduling.

### `calrs.yml`
This file defines the Docker Compose stack for CalRS. It includes the CalRS service, a backup service for the SQLite database, a volume for persistent data, and network configuration to connect to the Traefik proxy.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
CalRS uses SQLite for storage, which is a single-file database located at `/var/lib/calrs`. The `CALRS_BASE_URL` environment variable must be set to the public URL of the service (e.g., `https://cal.example.com`) so that OIDC redirect URIs and email links point to the correct host.

### Backup
The SQLite database is backed up using `sqlite3 .dump` with `gzip` compression. The backup interval and retention are defined in the environment variables `BACKUP_FREQUENCY` and `RETENTION_DAYS`.