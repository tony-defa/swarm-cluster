# MariaDB

MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system, intended to remain free and open-source software under the GNU General Public License.

### `mariadb.yml`
Contains the database and a service that creates a db dump in a regular interval.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure the database passwords.

- `mariadb_root_password`: The password for the root user
- `mariadb_db_database`: The database name
- `mariadb_db_user`: The database non root user
- `mariadb_db_password`: The password associated to the `mariadb_db_user` secret

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create --attachable -d overlay mariadb_network
```

## Other notes
### Backup 
The backup service uses `mariadb-dump` to dump the database to a file. The dump interval is defined in the environment variable `BACKUP_FREQUENCY`. The files are kept for `RETENTION_DAYS` while older files will be deleted automatically.

### Restore 
To restore a backup simply deploy the `mariadb` stack with an empty data volume. After that follow the instruction from the official documentation: https://mariadb.com/kb/en/restoring-data-from-dump-files/
> Use the `docker exec -t <service_name> ...` command to execute the restore command.

### `entrypoint.d` directory
The `entrypoint.d` folder is automatically mounted to the `mariadb` service, any script contained in that folder is executed by the `docker-entrypoint.sh` script from the official `mariadb` image. Read more about it on the [official documentation](https://hub.docker.com/_/mariadb/) under the `Initializing the database contents` section.