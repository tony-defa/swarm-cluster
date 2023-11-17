#!/bin/bash

DB_USER=$(cat /run/secrets/mariadb_ha_user)
DB_PASSWORD=$(cat /run/secrets/mariadb_ha_root_password)

echo '*****************************'
echo "Granting RELOAD and BINLOG MONITOR privileges to $DB_USER"
mariadb -u root -p$DB_PASSWORD -e \
"GRANT RELOAD, BINLOG MONITOR ON *.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;"
echo '*****************************'