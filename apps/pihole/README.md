# Pi-Hole

Pi-hole is a Linux network-level advertisement and Internet tracker blocking application which acts as a DNS sinkhole and optionally a DHCP server, intended for use on a private network.

### `pihole.yml`
Contains the pi-hole software.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure the startup passwords.

- `pihole_webpassword`: The password for the web interface

### Create network
No network needs to be created.

## Other notes
No notes