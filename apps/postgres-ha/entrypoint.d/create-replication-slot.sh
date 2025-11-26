#!/bin/bash

REPL_USER=$(cat /run/secrets/postgres_ha_replication_user)
REPL_PASSWORD=$(cat /run/secrets/postgres_ha_replication_password)

echo '*****************************'
echo "Creating replication slot for user $REPL_USER"
psql -U postgres -c "
  DO \$
  BEGIN 
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$REPL_USER') THEN 
      CREATE ROLE $REPL_USER WITH REPLICATION LOGIN PASSWORD '$REPL_PASSWORD';
    END IF; 
  END 
  \$;
  
  -- Create replication slot if it doesn't exist
  PERFORM pg_create_physical_replication_slot('replica_slot') 
  WHERE NOT EXISTS (SELECT FROM pg_replication_slots WHERE slot_name = 'replica_slot');
"
echo '*****************************'