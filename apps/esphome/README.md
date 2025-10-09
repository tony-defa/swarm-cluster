# ESPHome

ESPHome is a system to control your ESP8266/ESP32 devices by simple yet powerful configuration files and control them remotely through Home Assistant.

## `esphome.yml`

Contains the ESPHome server service in a Docker Swarm stack with Docker Swarm compatible configuration for device access.

## Prerequisites

### Storage
A centralized storage solution is required for ESPHome configuration files and firmware builds.

### Service dependencies
Mandatory stacks:
- `system/traefik.yml`
- `mustache/homeassistant/homeassistant.mustache` (or a deployed Home Assistant stack)
- The `macvlan_swarm` network must exist and be configured correctly.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created additionally to the `macvlan_swarm` network created by the `mustache/homeassistant/` stack.

## Other notes
### Docker Swarm Compatibility

This stack addresses the `privileged: true` requirement of ESPHome by using Docker Swarm compatible alternatives:

- **Capabilities**: `SYS_PTRACE`, `NET_ADMIN`, `NET_RAW` for device access
- **Security Options**: `no-new-privileges:false` for necessary permissions
- **Network Mode**: Connected to `macvlan_swarm` for Home Assistant communication

This approach provides the necessary permissions for USB device flashing and network operations while maintaining Docker Swarm compatibility.

### USB Device Access
If you encounter issues flashing devices via USB, ensure:
- Host USB devices are accessible (may need udev rules)
- Container has necessary capabilities for USB access
- Consider alternative flashing methods if USB access remains problematic

### Alternative Flashing Methods
If USB flashing doesn't work in Docker Swarm:
1. **ESPHome Web**: Use the web-based flashing tool
2. **esptool**: Flash firmware manually using `esptool.py`
3. **Pre-compiled Binaries**: Use the dashboard to compile firmware and flash manually
