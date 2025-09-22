# Graylog App

Graylog is a leading centralized log management solution for capturing, storing, and enabling real-time analysis of terabytes of machine data.

### `graylog.yml`
Contains graylog and the required backend for running properly.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available for first start. You might consider coping the data from an existing graylog instance to avoid reconfiguring everything.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
Configure each service that needs to log to graylog:

```yml
service-name:
  ...
  logging:
    driver: "gelf"
    options:
      gelf-address: "udp://172.17.0.1:12201"
  ...
```

> WARNING: Deploying this stack will expose port 12201 (udp) to the WWW. If you do not intend to have this port exposed than you need to block the port either via physical firewall or through software on each node. Example for the latter could look like this:

```sh
sudo iptables -I DOCKER-USER -i eth0 -p udp --dport 12201 -j DROP
```