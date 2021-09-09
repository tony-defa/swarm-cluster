# MariaDB

MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system, intended to remain free and open-source software under the GNU General Public License.

### `mariadb.yml`
Contains the database.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure the database passwords.

- `mariadb_root_password`: The password for the root user
- `mariadb_db_password`: The password associated to the `DB_USER` variable in the `.env`-file

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create -d overlay mariadb_network
```

## Other notes
No notes