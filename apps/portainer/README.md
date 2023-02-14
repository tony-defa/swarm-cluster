# Portainer

Portainer enables centralized configuration, management and security of Kubernetes and Docker environments, allowing you to deliver ‘Containers-as-a-Service’ to your users quickly, easily and securely.

### `portainer.yml`
Contains portainer itself and the agent that runs on every node. An additional service is used backup the portainer data once a week.

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
### Create scheduled Backups
The `SavageSoftware/portainer-backup` is used to create scheduled backups. Additional configurations can be found on their [GitHub Page](https://github.com/SavageSoftware/portainer-backup). For the backup process to work an access token is required to be entered in the `.env` file. Use the following instructions to create an access token: https://docs.portainer.io/api/access#creating-an-access-token

The above mentioned image does not contain a method to remove old backups at this time, so a third service is started withing the stack to remove these. Use the environment `RETENTION_DAYS` to define which backups should be removed.

### Restore Backup
To restore the portainer data from backup simply deploy the portainer stack with an empty data volume. Portainer will then start a fresh install. After that follow the instruction from the official documentation: https://docs.portainer.io/admin/settings#restoring-from-a-local-file