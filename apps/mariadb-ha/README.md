# MariaDB HA (High Availability)

MariaDB is an open source, community-developed SQL database server that is widely in use around the world due to its enterprise features, flexibility, and collaboration with leading tech firms.

### `mariadb.yml`
Contains the database as master and a slave service. It also contains a service that creates a db dump in a regular interval.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure the database passwords.

- `mariadb_ha_root_password`: The password for the root user
- `mariadb_ha_database`: The database name
- `mariadb_ha_user`: The database non root user
- `mariadb_ha_db_password`: The password associated to the `mariadb_ha_user` secret
- `mariadb_ha_repl_user`: The database non root user used for the replication.
- `mariadb_ha_repl_password`: The password associated to the `mariadb_ha_repl_user` secret.

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create -d overlay mariadb_ha_network
```

## Other notes
### Backup 
The backup service uses `mysqldump` to dump the database to a file. The dump interval is defined in the environment variable `BACKUP_FREQUENCY`. The files are kept for `RETENTION_DAYS` while older files will be deleted automatically.

### Restore 
To restore a backup simply deploy the `mariadb` stack with an empty data volume. After that follow the instruction from the official documentation: https://mariadb.com/kb/en/restoring-data-from-dump-files/
> Use the `docker exec -t <service_name> ...` command to execute the restore command.