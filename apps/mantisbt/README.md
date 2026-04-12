# MantisBT

Mantis Bug Tracker is a free and open source web-based bug tracking system.

### `mantisbt.yml`
MantisBT application stack with MariaDB database and automated backup service.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets:

- `mantisbt_db_database`: MantisBT database name
- `mantisbt_db_user`: Database username
- `mantisbt_db_password`: Database user password
- `mantisbt_db_root_password`: Database root password

### Create network
No network needs to be created.

## Other notes
No notes