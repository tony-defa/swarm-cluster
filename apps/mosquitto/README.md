# Eclipse Mosquitto

Eclipse Mosquitto is an open source message broker which implements MQTT version 5, 3.1.1 and 3.1

### `mosquitto.yml`
Contains only a basic mosquitto service.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
Copy the `example.conf` to create your custom Mosquitto configuration.

```sh
$ cp example.conf .conf
```

Edit the newly created `.conf` file to fit your needs. See [Eclipse Mosquitto Documentation](https://mosquitto.org/man/mosquitto-conf-5.html) for further information.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
No notes