# WordPress

The WordPress rich content management system can utilize plugins, widgets, and themes.

### `wordpress.yml`
Contains both wordpress and the underling database. There is also a script, that backups the wp files and database tables.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
No notes


cat .view.json | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' | xargs sudo mkdir -p
cat .view.json | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' | xargs sudo chown -R :docker
