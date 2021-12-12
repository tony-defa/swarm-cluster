# Nextcloud

A safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms.

### `nextcloud.yml`
Contains only the application without the underlying database.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `apps/mariadb.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secret to configure the admin user password.

- `nextcloud_admin_password`: The password for the admin user

External secrets from service dependencies are required.

### Create network
No network needs to be created.

## Other notes
No notes