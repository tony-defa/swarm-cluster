# Immich

Self-hosted photo and video backup solution from your mobile phone.

### `immich.yml`
Contains all Immich services in a Docker Swarm stack.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
### Backup
Immich has built-in backup functionality (see Immich docs). Implement regular backups of database and uploads.