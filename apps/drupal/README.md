# Drupal

Drupal is a flexible content management framework powering millions of websites and applications. This stack provides Drupal with a MariaDB database and an automated backup service.

### `drupal.yml`
Contains Drupal web, MariaDB database, and backup services. The backup service periodically dumps the database and archives the Drupal files, cleaning up backups older than the configured retention period.

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
No notes
