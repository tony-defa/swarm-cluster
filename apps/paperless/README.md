# Paperless-ngx

Paperless-ngx is a document management system that transforms your physical documents into a searchable online archive. It performs OCR on documents, automatically classifies them with machine learning, and provides a modern web UI for browsing, searching, and managing your document collection.

### `paperless.yml`

Contains the Paperless-ngx webserver, PostgreSQL database, Redis broker, and a backup service in a Docker Swarm stack.

## Prerequisites
### Storage
A centralized storage solution is required for persistent data, media files, exports, consumption directory, database, and backups.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets for sensitive data:

- `paperless_secret_key`: A long, random sequence of characters used as Django secret key
- `paperless_db_password`: The password for the PostgreSQL database user

### Create network
No network needs to be created.

## Other notes
### Backup
The backup service creates a PostgreSQL database dump and archives the data and media directories. The backup interval is defined in `BACKUP_FREQUENCY` and retention in `RETENTION_DAYS`.

### Consumption
Place documents for import into the consume directory (`HOST_PAPERLESS_CONSUME`). Paperless-ngx automatically processes documents placed there.

### Paperless-ngx documentation
For all available configuration options, refer to the official documentation at https://docs.paperless-ngx.com/configuration/