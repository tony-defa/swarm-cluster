# Vaultwarden
Vaultwarden is a lightweight, unofficial Bitwarden server implementation written in Rust. It is compatible with official Bitwarden clients and is designed for personal use and small organizations.

### `vaultwarden.yml`
This file defines the Docker Compose stack for Vaultwarden. It includes the Vaultwarden service, volume definitions for persistent data, and network configuration to connect to the Traefik proxy.

## Perquisites
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
No notes