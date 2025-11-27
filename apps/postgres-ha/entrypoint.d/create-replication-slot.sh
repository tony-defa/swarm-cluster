#!/bin/bash
set -e

REPL_USER=$(cat /run/secrets/postgres_ha_replication_user)
REPL_PASSWORD=$(cat /run/secrets/postgres_ha_replication_password)

echo '*****************************'
echo "Creating replication slot for user $REPL_USER"

psql -U postgres <<-'EOSQL'
  -- Create replication role if not exists
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles WHERE rolname = '$REPL_USER'
    ) THEN
      EXECUTE format(
        'CREATE ROLE %I WITH REPLICATION LOGIN PASSWORD %L',
        '$REPL_USER', '$REPL_PASSWORD'
      );
    END IF;
  END
  $$;

  -- Create physical replication slot if it doesn't exist
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM pg_replication_slots WHERE slot_name = 'replica_slot'
    ) THEN
      PERFORM pg_create_physical_replication_slot('replica_slot');
    END IF;
  END
  $$;
EOSQL

echo '*****************************'
