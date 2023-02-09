# Nexus

The free artifact repository with universal format support.

### `nexus.yml`
Contains the nexus3 application

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
### Backup
Unlike some other stacks, there is no backup service with the nexus stack. A backup task to backup the underlying database can be configured within the settings of nexus. Follow the official instructions to setup a backup task: https://help.sonatype.com/repomanager3/planning-your-implementation/backup-and-restore/configure-and-run-the-backup-task

A backup volume is made available with the `HOST_NEXUS_BACKUP` environment variable. The mount point within the docker container is `/backup`.

### Restore
To restore the exported databases follow the instructions here: https://help.sonatype.com/repomanager3/planning-your-implementation/backup-and-restore/restore-exported-databases 