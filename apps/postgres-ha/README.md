# PostgreSQL HA (High Availability)

PostgreSQL is a powerful, open-source object-relational database system known for its reliability, feature robustness, and performance. This stack provides a high-availability PostgreSQL setup with master-replica streaming replication and automated backups.

### `postgres.yml`
Contains the database as master and a replica service. It also contains a service that creates a database dump in regular intervals. The replica service uses PostgreSQL's streaming replication with base backup initialization to ensure fast startup times.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure the database passwords.

- `postgres_ha_root_password`: The password for the root user
- `postgres_ha_database`: The database name
- `postgres_ha_user`: The database non root user
- `postgres_ha_password`: The password associated to the `postgres_ha_user` secret
- `postgres_ha_replication_user`: The database user used for replication
- `postgres_ha_replication_password`: The password associated to the `postgres_ha_replication_user` secret

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create -d overlay postgres_ha_network
```

## Other notes
### Replication
The replica service uses PostgreSQL's streaming replication. When the replica starts up, it first performs a base backup from the master using `pg_basebackup` to get an initial synchronized copy. After the base backup, it switches to streaming replication to receive ongoing changes from the master.

This approach prevents the slow catch-up that would occur if the replica tried to replay all WAL entries since the master's creation. The base backup ensures the replica starts with current data and only needs to apply recent changes.

To check the replication status from within the master instance, you can run the following command: `docker exec -it <postgres-primary-name> psql -U postgres -c "SELECT * FROM pg_stat_replication;"`

### Backup 
The backup service uses `pg_dump` to create logical backups of the database. The dump interval is defined in the environment variable `BACKUP_FREQUENCY`. The files are kept for `RETENTION_DAYS` while older files will be deleted automatically.

The backup is created with the `--clean --no-owner --create` options, making it suitable for restoring to a fresh database instance.

### Restore 
To restore a backup simply deploy the `postgres` stack with an empty data volume. After that, use the following command to restore from the backup file:

```sh
$ docker exec -i <container_name> psql -U <username> -d <database_name> < /path/to/backup/file.sql
```

### `entrypoint.d` directory
The `entrypoint.d` folder is automatically mounted to the `postgres` service, any script contained in that folder is executed by the `docker-entrypoint.sh` script from the official `postgres` image. The `create-replication-slot.sh` script automatically creates the replication user and replication slot needed for streaming replication.

### Replica Service Behavior
The replica service handles its own initialization through its custom command. On first startup, it performs a `pg_basebackup` to get a synchronized copy from the master, then configures itself for streaming replication. This eliminates the need for a separate initialization service.

## PostgreSQL vs MariaDB Replication Differences

Unlike MariaDB's binary log replication, PostgreSQL uses Write-Ahead Log (WAL) streaming replication. Key differences:

- **Base Backup**: PostgreSQL replicas perform a `pg_basebackup` to get an initial synchronized copy, avoiding the need to replay all historical WAL entries
- **Streaming Replication**: Uses physical replication slots to stream WAL data in real-time
- **No CHANGE MASTER TO**: PostgreSQL uses `standby.signal` and `postgresql.auto.conf` files for replica configuration instead of SQL commands
- **Faster Startup**: New replicas start much faster since they begin with current data rather than replaying from the beginning