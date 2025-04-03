# Music Assistant

Music Assistant is a music library manager that connects with popular streaming services and your local music files.

### `music-assistant.yml`
Contains the Music Assistant server service in a Docker Swarm stack.

## Prerequisites

### Storage
Centralized storage is recommended for persistent data. Consider NFS or similar for cluster-wide access.

### Service dependencies
Mandatory stacks:
- `mustache/homeassistant/homeassistant.mustache` (or a deployed Home Assistant stack)
- The `macvlan_swarm` network must exist and be configured correctly.

### Create pre-configured data folder
Create the host directory for persistent data if using host volumes (recommended for production).
Refer to `example.env` for the volume path variable (`HOST_MUSIC_ASSISTANT_DATA`).

Example command:
```sh
mkdir -p /cluster/music-assistant/data
sudo chown -R :docker /cluster/music-assistant/data
```

### Create docker secrets
No docker secrets are required for this stack.

### Create network
This stack requires the external `macvlan_swarm` network, which should be created and managed separately (likely by the Home Assistant stack or system configuration).

## Other notes

### Network Configuration
Music Assistant requires specific network access (originally `network_mode: host`). This stack uses the `macvlan_swarm` network as requested, which should provide the necessary network visibility. Ensure your `macvlan_swarm` network is correctly configured for your environment.

### SMB/CIFS Mounts
The original Docker Compose configuration included capabilities (`cap_add`, `security_opt`) for mounting SMB/CIFS shares directly within the container. These options are not directly supported in Docker Swarm `deploy` sections. If you need to access SMB/CIFS shares, consider mounting them on the host node(s) where the service runs and then bind-mounting the host path into the container, or explore alternative solutions like NFS.