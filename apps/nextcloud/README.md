# Nextcloud

A safe home for all your data. Access & share your files, calendars, contacts, mail & more from any device, on your terms.

### `nextcloud.yml`
Contains only the application without the underlying database and also provides a backup service running on an alpine image.

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

- `nextcloud_admin_user`: The password for the admin user
- `nextcloud_admin_password`: The password for the admin user

External secrets from service dependencies are required.

### Create network
No network needs to be created.

## Other notes
### Backup
The backup service securely backs up the all data files into a compressed tar archive. The backup interval is defined in the environment variable `BACKUP_FREQUENCY`. Old archives are deleted automatically after the amount of days specified in the environment variable `RETENTION_DAYS`. 

The database is not backed up by this service. This is taken care of the separate database stack found in `apps/mariadb.yml`.