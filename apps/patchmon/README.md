# PatchMon

PatchMon is an open-source, enterprise-grade Linux (and optional FreeBSD / Windows) patch management and infrastructure monitoring platform. It provides a single pane of glass to monitor, patch and secure a fleet of servers via a lightweight outbound-only agent. Self-hosting is free under the AGPL v3 license; a managed cloud offering is also available.

### `patchmon.yml`

Contains the full PatchMon stack: the `server` (Go binary with embedded React frontend), a dedicated `database` (PostgreSQL 17), a `redis` instance for the Asynq job queue / cache, a `guacd` sidecar used for in-browser RDP (Windows hosts) and a `backup` service that performs periodic `pg_dump` snapshots of the database.

## Prerequisites

### Storage

A centralized storage solution is required. Three host paths must be reachable by the manager nodes and will be bind-mounted into the database, redis and backup containers respectively:

| Path (set in `example.env`)  | Purpose                                |
| ---------------------------- | -------------------------------------- |
| `HOST_PATCHMON_DB_PATH`      | PostgreSQL data directory              |
| `HOST_PATCHMON_REDIS_PATH`   | Redis AOF/RDB persistence              |
| `HOST_PATCHMON_BACKUP_PATH`  | Local `pg_dump` archive storage        |

Create the directories before deploying:

```sh
sudo mkdir -p /cluster/patchmon_data/{database,redis,backup}
sudo chown -R :docker /cluster/patchmon_data
sudo chmod -R g+w /cluster/patchmon_data
```

Alternatively uncomment the `device: ":/cluster/...` and `type: nfs` lines in `patchmon.yml` and set `NFS_SHARE_IP` in your `.env` to back the volumes with NFS.

### Service dependencies

Mandatory stacks are:

- `system/traefik.yml` (provides the `proxy_network` overlay network and the entrypoint used in the `ENTRYPOINT` variable)

### Create pre-configured data folder

No pre-configured data folder is required. The PatchMon server creates its schema on first boot.

### Create docker secrets

PatchMon requires five secrets. Create them once on a manager node before the first deployment. The `deploy-stack.sh` helper script will interactively prompt for missing secrets (it requires `yq`), but you can also create them manually:

```sh
# PostgreSQL password (32-byte random hex)
openssl rand -hex 32 | docker secret create patchmon_postgres_password -

# Redis password (32-byte random hex)
openssl rand -hex 32 | docker secret create patchmon_redis_password -

# JWT signing secret (64-byte random hex)
openssl rand -hex 64 | docker secret create patchmon_jwt_secret -

# Session encryption secret (64-byte random hex)
openssl rand -hex 64 | docker secret create patchmon_session_secret -

# AI / settings encryption key (64-byte random hex)
openssl rand -hex 64 | docker secret create patchmon_ai_encryption_key -
```

The values for `POSTGRES_PASSWORD`, `REDIS_PASSWORD`, `JWT_SECRET`, `SESSION_SECRET` and `AI_ENCRYPTION_KEY` in your `.env` file **must** match the corresponding Docker secret (the server service reads them from the environment; the database / redis services read them from the mounted `*_FILE` secret).

### Create network

No additional networks need to be created manually. The `patchmon_network` overlay network is created automatically by the stack on deploy, and the `proxy_network` is created by the Traefik system stack.

## Other notes

### Agent enrolment

Once the stack is running, log in to the PatchMon web UI at `https://${DOMAIN}`, create the first user (which is automatically promoted to `superadmin`) and add a host. The UI generates a one-line install command containing a per-host API key. Run that command on any Linux, FreeBSD or Windows host you wish to monitor.

Agents connect outbound-only on port `443` (HTTPS) plus a WebSocket channel for live patch streaming and Docker status updates. **No inbound firewall rules** are required on managed hosts.

### WebSocket support

Live patch runs and Docker event streaming use WebSockets. The Traefik stack already supports WebSocket passthrough by default, so no extra middleware configuration is required. If you front PatchMon with a different reverse proxy, ensure it forwards the `Upgrade` / `Connection` headers.

### Resource usage

Minimum recommended sizing for the control-plane services:

| Service   | CPU  | Memory |
| --------- | ---- | ------ |
| `server`  | 0.5  | 512 MB |
| `database`| 0.5  | 512 MB |
| `redis`   | 0.25 | 128 MB |
| `guacd`   | 1.0  | 512 MB |

The `guacd` service in this stack is pre-configured with `mem_limit: 512m` / `cpus: "1.0"` because it is the most resource-hungry component (in-browser RDP). All other services inherit Swarm defaults; tune them with the standard `deploy.resources` keys if you have a large fleet.

### Backup

The `backup` service uses the `postgres:${POSTGRES_TAG}` image and `pg_dump` to take a full logical backup of the PatchMon database into `${HOST_PATCHMON_BACKUP_PATH}`. The frequency is controlled with `BACKUP_FREQUENCY` (default `24h`) and old archives are deleted after `RETENTION_DAYS` (default `14`).

The backup covers PostgreSQL only. PatchMon's data model lives entirely in the database, so this is sufficient for a full restore. Custom logos and themes are also stored in the database.

To restore from a backup, deploy the stack with an empty `postgres_data` volume and let the server initialise, then load the dump:

```sh
# Inside a one-off container that can reach the database service
PGPASSWORD="<value of patchmon_postgres_password secret>" \
  pg_restore -h <db_host> -U patchmon_user -d patchmon_db \
    --clean --if-exists --no-owner --no-privileges \
    /backup/patchmon_db_<timestamp>.dump
```

### Upgrading

PatchMon publishes rolling minor/patch tags (`x.y` and `x.y.z`). Update `PATCHMON_TAG` in `.env` and redeploy:

```sh
docker pull ghcr.io/patchmon/patchmon-server:${PATCHMON_TAG}
./deploy-stack.sh apps/patchmon/patchmon.yml patchmon
```

Because the `server` service uses `order: start-first` in its `update_config`, the new container starts before the old one stops, minimising downtime.

### License

PatchMon is licensed under the **GNU Affero General Public License v3 (AGPLv3)**. Self-hosting the unmodified upstream image for your own use (including commercial use) is permitted. If you modify PatchMon and expose the modified version to third parties over a network, the AGPL requires you to make the corresponding source available to those users. The Docker images used here (`ghcr.io/patchmon/patchmon-server`, `postgres`, `redis`, `guacamole/guacd`) keep their respective upstream licenses.

### References

- PatchMon project: <https://patchmon.net/>
- Documentation:     <https://patchmon.net/docs>
- GitHub:            <https://github.com/PatchMon/PatchMon>
- Operator guide:    <https://patchmon.net/docs/patchmon-operator-guide>
