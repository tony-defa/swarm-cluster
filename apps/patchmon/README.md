# PatchMon

PatchMon is an open-source, enterprise-grade patch management and infrastructure monitoring platform. Lightweight outbound-only agents report package, compliance and host data to a central server. Self-hosted under the AGPL v3 license.

### `patchmon.yml`
Contains the PatchMon server, its PostgreSQL database, Redis job queue/cache, the guacd sidecar for in-browser RDP (Windows hosts) and a backup service that periodically runs `pg_dump` on the database.

## Prerequisites
### Storage
A centralized storage solution is required. Three host paths must exist on the manager nodes:

- `HOST_PATCHMON_DB_PATH` - PostgreSQL data directory
- `HOST_PATCHMON_REDIS_PATH` - Redis persistence directory
- `HOST_PATCHMON_BACKUP_PATH` - pg_dump archive directory

For NFS-backed volumes uncomment the `device: ":..."` and `type: nfs` lines in `patchmon.yml` and set `NFS_SHARE_IP`.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure startup credentials. Each value must match the corresponding variable in the `.env` file.

- `patchmon_postgres_password`: PostgreSQL password (32-byte random hex)
- `patchmon_redis_password`: Redis password (32-byte random hex)
- `patchmon_jwt_secret`: JWT signing secret (64-byte random hex)
- `patchmon_session_secret`: session encryption secret (64-byte random hex)
- `patchmon_ai_encryption_key`: AI/settings encryption key (64-byte random hex)

### Create network
No network needs to be created. The `patchmon_network` overlay is created automatically on deploy.

## Other notes
### Agent enrolment
Once the stack is running, open the UI at `${DOMAIN}` and create the first user (automatically promoted to `superadmin`). Add a host in the UI and copy the generated one-line install command to that host. Agents connect outbound-only on port `443` (HTTPS + WebSocket); no inbound firewall rules are required on managed hosts.

### Backup
The `backup` service performs a `pg_dump` of the PatchMon database into `${HOST_PATCHMON_BACKUP_PATH}`. Frequency and retention are controlled with `BACKUP_FREQUENCY` and `RETENTION_DAYS`. PatchMon stores all of its state in PostgreSQL (including custom logos), so a `pg_dump` is sufficient for a full restore.

### Restore
Deploy the stack with an empty `postgres_data` volume to start fresh, then load the dump:

```sh
PGPASSWORD="<value of patchmon_postgres_password>" \
  pg_restore -h database -U patchmon_user -d patchmon_db \
    --clean --if-exists --no-owner --no-privileges \
    /backup/patchmon_db_<timestamp>.dump
```

### Upgrading
Bump `PATCHMON_TAG` in `.env` and redeploy. The `server` uses `order: start-first` so the new container starts before the old one stops.
