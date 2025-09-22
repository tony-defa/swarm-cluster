# Logrotate from blacklabelops

This container can crawl for logfiles and rotate them. It is a side-car container for containers that write logfiles and need a log rotation mechanism. Just hook up some containers and define your backup volumes.

### `logrotate.yml`
Contains only the logrotate service.

## Prerequisites
### Storage
A centralized storage solution is not required.

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