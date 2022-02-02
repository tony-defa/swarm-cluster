# WhoAmI

Prometheus is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true. Read more on the [Prometheus website](https://prometheus.io/).

### `prometheus.yml`
Contains only the prometheus service.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
A configuration is required for prometheus to scrape data from other targets. Run the following commands to complete this step:

```sh
$ chmod +x ./create_prometheus_data.sh
$ sudo ./create_prometheus_data.sh
```

> Use the `sudo` command, if the path of the configured `HOST_PROMETHEUS_DATA` variable does not reside in your home directory. Omit `sudo` otherwise.
> For NFS configuration: Edit the script at the end and use `nobody:nogroup` as owner for the created directory with the `chown` command.

After executing the script, the config files will be placed in the `HOST_PROMETHEUS_DATA` directory and can be edited to fit your needs.

### Create docker secrets
No docker secrets are required.

### Create network
Create a overlay network for the metrics collection.

```sh
$ docker network create -d overlay metrics_network
```

## Other notes
The prometheus application is running on port `9999` in this configuration.

Prometheus is running with the `--web.enable-lifecycle` flag. This means that the configuration files can be reloaded at runtime,
when sending a HTTP POST request to the /-/reload endpoint. This will also reload any configured rule files.