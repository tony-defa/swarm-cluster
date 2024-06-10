# Mosquitto MQTT Broker

Mosquitto is an open source message broker that implements the MQTT protocol. It is lightweight and is suitable for use on all devices from low power single board computers to full servers.

### `mqtt.yml`
Contains the mosquitto MQTT broker.

## Perquisites
### Storage
A centralized storage solution is required, if some custom configuration is needed.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No secrets are required for this service.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create --attachable -d overlay mqtt_network
```

## Other notes