# PostgreSQL HA (High Availability)

PostgreSQL is a powerful, open-source object-relational database system known for its reliability, feature robustness, and performance. This stack provides a high-availability PostgreSQL setup with master-replica streaming replication and automated backups.

### `postgres.yml`
Contains the database as master and a replica service. It also contains a service that creates a database dump in regular intervals. The replica service uses PostgreSQL's streaming replication with base backup initialization to ensure fast startup times.

## Prerequisites
### Storage
A centralized storage solution is required for persistent model storage.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
The stack now uses separate configuration files:
- `.postgresql.db.conf`: Main PostgreSQL configuration for the master database
- `.postgresql.replica.conf`: Template configuration for the replica (used as `postgresql.auto.conf.template`)
- `.pg_hba.db.conf`: Client authentication configuration (used as `pg_hba.conf`)
Copy `example.postgresql.db.conf`, `example.postgresql.replica.conf`, and `example.pg_hba.db.conf` to create your custom configuration.

```sh
cp config/example.postgresql.db.conf config/.postgresql.db.conf
cp config/example.postgresql.replica.conf config/.postgresql.replica.conf
cp config/example.pg_hba.db.conf config/.pg_hba.db.conf
```

Edit the newly created config files to fit your needs. The `.postgresql.db.conf` configuration file is used for the master service, the `.postgresql.replica.conf` configuration file is for the replica service, and the `.pg_hba.db.conf` file configures client authentication. See [Postgres Documentation](https://www.postgresql.org/docs/18/runtime-config.html) for further information about postgresql.conf settings and [pg_hba.conf documentation](https://www.postgresql.org/docs/18/auth-pgodd.html) for authentication configuration.

### Create docker secrets
Create the following docker secrets to configure the database passwords.

- `postgres_ha_password`: The password for the postgres user
- `postgres_ha_replication_user`: The database user used for replication
- `postgres_ha_replication_password`: The password associated to the `postgres_ha_replication_user` secret

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
docker network create --attachable -d overlay postgres_ha_network
```

## Other notes
### Replication
The replica service uses PostgreSQL's streaming replication. When the replica starts up, it executes a custom setup script (`setup-replica.sh`) that first performs a base backup from the master using `pg_basebackup` to get an initial synchronized copy. After the base backup, it configures itself for streaming replication to receive ongoing changes from the master.

This approach prevents the slow catch-up that would occur if the replica tried to replay all WAL entries since the master's creation. The base backup ensures the replica starts with current data and only needs to apply recent changes.

To check the replication status from within the master instance, you can run the following command: `docker exec -it <postgres-primary-name> psql -U postgres -c "SELECT * FROM pg_stat_replication;"`

### Backup
The backup service uses `pg_dump` to create logical backups of the database. The backup schedule is defined using a cron string in the environment variable `BACKUP_CRON`. The files are stored in `/master/backup` directory and kept for `RETENTION_DAYS` while older files will be deleted automatically.

The backup is created with the `--clean --no-owner --create` options, making it suitable for restoring to a fresh database instance.

#### Backup Schedule Configuration
The `BACKUP_CRON` variable uses standard cron format: `minute hour day month weekday`

Examples:
- `0 2 * * *` - Daily at 2 AM
- `0 */6 * * *` - Every 6 hours
- `0 3 * * 0` - Weekly on Sunday at 3 AM
- `0 1 1 * *` - Monthly on the 1st at 1 AM

### Restore
To restore a backup simply deploy the `postgres` stack with an empty data volume. After that, use the following command to restore from the backup file:

```sh
docker exec -i <container_name> psql -U postgres -d <database_name> < /path/to/backup/file.sql
```

### `entrypoint.d` directory
The `entrypoint.d` folder is automatically mounted to the `postgres` service, any script contained in that folder is executed by the `docker-entrypoint.sh` script from the official `postgres` image. The `create-replication-slot.sh` script automatically creates the replication user and replication slot needed for streaming replication.