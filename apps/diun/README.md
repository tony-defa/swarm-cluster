# Diun

Docker Image Update Notifier is a CLI application written in Go and delivered as a single executable (and a Docker image) to receive notifications when a Docker image is updated on a Docker registry.

### `diun.yml`
Contains only the diun service.

## Prerequisites
### Storage
A centralized storage solution is not required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
Copy the `example.yml` to create your custom Diun configuration.

```sh
$ cp example.yml .yml
```

Edit the newly created `.yml` file to fit your needs. See [Diun Documentation](https://crazymax.dev/diun/config/) for further information.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
No notes