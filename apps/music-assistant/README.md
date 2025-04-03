# Music Assistant

Music Assistant is a music library manager that connects with popular streaming services and your local music files.

### `music-assistant.yml`
Contains the Music Assistant server service in a Docker Swarm stack.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks:
- `system/traefik.yml`
- `mustache/homeassistant/homeassistant.mustache` (or a deployed Home Assistant stack)
- The `macvlan_swarm` network must exist and be configured correctly.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required for this stack.

### Create network
No network needs to be created additionally to the `macvlan_swarm` network created by with the `mustache/homeassistant/` stack.

## Other notes
### SMB/CIFS Mounts
The original Docker Compose configuration included capabilities (`cap_add`, `security_opt`) for mounting SMB/CIFS shares directly within the container. These options are not directly supported in Docker Swarm `deploy` sections. If you need to access SMB/CIFS shares, consider mounting them on the host node(s) where the service runs and then bind-mounting the host path into the container, or explore alternative solutions like NFS.