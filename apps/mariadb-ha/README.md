# MariaDB HA (High Availability)

MariaDB is an open source, community-developed SQL database server that is widely in use around the world due to its enterprise features, flexibility, and collaboration with leading tech firms.

### `mariadb.yml`
Contains the database as master and a slave service.

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
- `mariadb_ha_db_password`: The password associated to the `DB_USER` variable in the `.env`-file
- `mariadb_ha_replication_password`: The password for database replication

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create -d overlay mariadb_ha_network
```

## Other notes
No notes