# Home Assistant

This stack provides Home Assistant, an open-source home automation platform, along with optional Zigbee2MQTT and Mosquitto MQTT broker, deployed as Docker Swarm services using a mustache template for dynamic configuration.

### `homeassistant.mustache`

This file is a mustache template for the Docker Compose stack file. It defines the services for Home Assistant, Mosquitto MQTT broker (optional), and Zigbee2MQTT (optional), along with volumes, networks, and deployment configurations. The template uses variables defined in the `example.view.json` file to dynamically generate the stack file.

### `example.view.json`

This file contains the data in JSON format that is injected into the `homeassistant.mustache` template. It includes configuration options for:

- Host volume paths for persistent data storage
- Docker image tags for Home Assistant, Zigbee2MQTT, and Mosquitto MQTT
- Proxy routing rules for Traefik
- Port configurations
- Feature flags to enable/disable Zigbee2MQTT
- Backup configurations
- Network File System (NFS) share IP for volume storage

To customize the stack, copy `example.view.json` to `.view.json` (or add e.g. `.test` prefix to the filename to run multiple capsulated stacks) and modify the values according to your environment and requirements.

## Prerequisites

### Storage

A centralized storage solution is required for persistent data storage of Home Assistant configurations, Zigbee2MQTT data, and MQTT broker data. Configure the host volume paths in your `.view.json` file.

### Service dependencies

Mandatory stacks are:

- `system/traefik.yml`: Traefik is used as a reverse proxy to expose Home Assistant and Zigbee2MQTT web interfaces.

### Create pre-configured data folder

Copy the `config/configuration.yaml` to create your custom Home Assistant configuration.

```sh
$ cp config/configuration.yaml "$(cat .view.json | jq -r '.host_ha_data')/configuration.yaml"
```

Edit the copied `configuration.yaml` file to fit your needs. See [Home Assistant Documentation](https://www.home-assistant.io/docs/configuration/) for further information.

### Create Matter Server configuration (optional)

Copy the `config/matter-server.yaml` to create your custom Matter Server configuration.

```sh
$ cp config/matter-server.yaml "$(cat .view.json | jq -r '.host_matter_data')/matter-server.yaml"
```

Edit the copied `matter-server.yaml` file to customize Matter Server settings. This file is optional as the Matter Server will work with default settings.

### Create docker secrets

No docker secrets are required for this stack.

### Create network

The following networks may need to be created before deploying the stack:

- `macvlan_swarm`: Required for Home Assistant to be accessible on the local network. Follow the instructions in [here](#network-configuration-for-macvlan_swarm) to create this network.

If you are using Zigbee2MQTT, you may need to create the `mqtt_network`:

```sh
$ docker network create --attachable -d overlay mqtt_network
```

## Other notes

### HA, z2m, and Matter Server backup

Backup is created automatically for Zigbee2MQTT daily at 4 am. For Home Assistant, automatic backups (starting with version 2025.1) need to be configured within Home Assistant, and they are set to start at 4:45 AM. The Matter Server backup runs daily at 5:30 AM. Backups are then moved to a separate directory at 5 AM (HA) and 5:30 AM (Matter) respectively, and retained for the number of days defined by `backup_retention_days` in `.view.json`. Remember to save the Home Assistant encryption key for restoring backups.

### HA Configuration

To ensure proper operation behind Traefik, add the following configuration to your Home Assistant `configuration.yaml` file:

```yml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - 10.0.0.0/16 # traefik proxy subnet
```

### Bluetooth

If you need Bluetooth functionality within Home Assistant, run the following command from within the Home Assistant container:

```sh
bluetoothctl power on
```

### Mosquitto MQTT Broker

This stack includes an optional Mosquitto MQTT broker. Mosquitto is a lightweight open-source message broker that implements the MQTT protocol, suitable for various devices from low-power single-board computers to full servers.

### Matter Server

This stack includes an optional Matter Server using the `ghcr.io/home-assistant-libs/python-matter-server:stable` image. Matter is a new smart home connectivity standard that enables communication across multiple IoT ecosystems.

#### Matter Server Features
- **Thread Network Support**: Enables Thread border router functionality
- **Bluetooth Commissioning**: Local commissioning via Bluetooth for device setup
- **mDNS Support**: Automatic device discovery on the local network
- **Home Assistant Integration**: Seamless integration with Home Assistant's Matter integration

#### Matter Server Configuration
The Matter Server is configured with:
- Host networking for mDNS and Thread support
- D-Bus access for Bluetooth functionality
- Data persistence through dedicated volume storage
- Node placement constraints for hardware device access
- Automated backup system

#### Network Requirements for Matter
The Matter Server requires host networking mode for proper operation:
- **mDNS**: Required for device discovery
- **Thread Protocol**: Requires direct network access
- **Bluetooth**: Needs D-Bus access for commissioning

#### Service Dependencies
Optional stacks are:
- No additional mandatory dependencies beyond Traefik

### Network Configuration for `macvlan_swarm`

The `macvlan_swarm` network is crucial for allowing Home Assistant to communicate directly on your local network. Follow these steps to create the network:

1. **Create macvlan network configurations for each node:**

   Replace `192.168.0.0/24`, `192.168.0.1`, `eth0`, `192.168.0.232/29`, `192.168.0.240/29`, and `192.168.0.248/29` with your network settings. Adjust the IP ranges according to the number of nodes in your swarm.

   ```sh
   # create a macvlan network for each node
   # start with the first node
   docker network create --config-only --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0 --ip-range 192.168.0.232/29 macvlan_local
   # create the network on the second node
   docker network create --config-only --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0 --ip-range 192.168.0.240/29 macvlan_local
   # create the network on the third node
   docker network create --config-only --subnet=192.168.0.0/24 --gateway=192.168.0.1 -o parent=eth0 --ip-range 192.168.0.248/29 macvlan_local
   ```

2. **Create the macvlan swarm network:**

   ```sh
   # create the macvlan network on the swarm
   docker network create -d macvlan --scope swarm --config-from macvlan_local macvlan_swarm
   ```