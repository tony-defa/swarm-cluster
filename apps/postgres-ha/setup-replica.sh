#!/bin/bash
set -e

# Setup environment variables from secrets
export PG_USER=$(cat /run/secrets/postgres_ha_replication_user)
export PG_PASSWORD=$(cat /run/secrets/postgres_ha_replication_password)
export PG_PATH="${PGDATA:-/var/lib/postgresql}"

# Wait for master to be ready
until pg_isready -h db -p 5432; do
  echo "Waiting for master database to be available..."
  sleep 2
done

# Check if data directory is empty (first time setup)
if [ -z "$(ls -A $PG_PATH)" ]; then

  echo "Setting up replica from master via base_backup..."

  mkdir -p "$PG_PATH"
  chmod 700 "$PG_PATH"
  
  # Create replication user if not exists
  PGPASSWORD=$(cat /run/secrets/postgres_ha_password) \
  psql -U postgres -h db -c "
    DO \$\$ 
    BEGIN 
      IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles 
        WHERE rolname = '$PG_USER'
      ) THEN 
        CREATE ROLE $PG_USER
        WITH REPLICATION LOGIN PASSWORD '$(cat /run/secrets/postgres_ha_replication_password)';
      END IF; 
    END 
    \$\$;"

  
  # Perform base backup
PGPASSWORD=$(cat /run/secrets/postgres_ha_replication_password) pg_basebackup \
    -h db \
    -D $PG_PATH \
    -U $PG_USER \
    -v \
    -P \
    -W
  
  # Copy standby configuration
  echo "# Standby mode configuration" > $PG_PATH/standby.signal
  
  # Create recovery configuration with secrets substitution
  awk '{
    while (match($0, /\$\{[A-Za-z_][A-Za-z0-9_]*\}/)) {
      var = substr($0, RSTART+2, RLENGTH-3)
      gsub("\\$\\{" var "\\}", ENVIRON[var] ? ENVIRON[var] : "")
    }
    print
  }' /etc/postgresql/postgresql.auto.conf.template > $PG_PATH/postgresql.auto.conf
fi

# Start PostgreSQL in standby mode
exec docker-entrypoint.sh postgres