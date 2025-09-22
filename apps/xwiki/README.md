# XWiki

XWiki is a free wiki software platform written in Java with a design emphasis on extensibility. XWiki is an enterprise wiki. It includes WYSIWYG editing, OpenDocument based document import/export, semantic annotations and tagging, and advanced permissions management.

### `xwiki.yml`
Contains only the application without the underlying database and also provides a backup service running on an alpine image.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`
- `apps/mariadb.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
External secrets from service dependencies are required.

### Create network
No network needs to be created.

## Other notes
### Backup
The backup service securely backs up the configuration files `xwiki.cfg`, `xwiki.properties` and `hibernate.cfg.xml` into a compressed tar archive. Old archives are deleted automatically after the amount of days specified in the environment variable `RETENTION_DAYS`. 

The database is not backed up by this service. This is taken care of the separate database stack found in `apps/mariadb.yml`.