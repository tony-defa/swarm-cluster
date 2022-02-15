# System services

Prometheus is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true. Read more on the [Prometheus website](https://prometheus.io/).

Grafana is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.

Traefik is an open-source Edge Router that makes publishing your services a fun and easy experience. It receives requests on behalf of your system and finds out which components are responsible for handling them.

Portainer enables centralized configuration, management and security of Kubernetes and Docker environments, allowing you to deliver ‘Containers-as-a-Service’ to your users quickly, easily and securely.

### `monitoring.yml`
Contains monitoring services like prometheus, grafana, etc.

### `traefik.yml`
Contains traefik configured for execution with docker swarm.

### `portainer.yml`
Contains portainer itself and the agent that runs on every node.

## Perquisites
### Storage
A centralized storage solution is required for the following stacks:
- `monitoring.yml`
- `traefik.yml`
- `portainer.yml`

### Service dependencies
`traefik.yml` requires the following network to exist (see [this](#create-network) section):
- `metrics_network`

`monitoring.yml` and `portainer.yml` require the following stack to run:
- `traefik.yml`

### Create pre-configured data folder
A configuration is required for prometheus to scrape data from other targets. Run the following commands to complete this step:

```sh
$ chmod +x ./create_prometheus_data.sh
$ sudo ./create_prometheus_data.sh
```

After executing the script, the config files will be placed in the `HOST_PROMETHEUS_DATA` directory and can be edited to fit your needs.

For traefik to work properly some configuration steps are necessary. Run the following commands to complete this step:

```sh
$ chmod +x ./create_traefik_data.sh
$ sudo ./create_traefik_data.sh
```

> Use the `sudo` command, if the path of the configured `HOST_TRAEFIK_DATA` and/or `HOST_PROMETHEUS_DATA` variable does not reside in your home directory. Omit `sudo` otherwise.
> For NFS configuration: Edit the script at the end and use `nobody:nogroup` as owner for the created directory with the `chown` command.

To create a basic auth account use the following commands (optional)

```sh
$ sudo apt install apache2-utils
$ htpasswd -nb <user> <password> | sudo tee "$(cat .env | grep "HOST_TRAEFIK_PATH" | cut -d'=' -f2)/users.txt"
```
> Replace the `<user>` and `<password>`placeholders.
> Use `sudo` command as explained above.

It is now possible to add the `user-auth` middleware as a service label [see here](#traefik). This will make sure that a route is only available after valid credentials have been provided.

### Create docker secrets
No docker secrets are required.

### Create network
Create a overlay network for the metrics collection and one for the proxy (traefik).

```sh
$ docker network create -d overlay metrics_network
$ docker network create -d overlay public_network
```

## Other notes
### Prometheus
Prometheus is running with the `--web.enable-lifecycle` flag. This means that the configuration files can be reloaded at runtime,
when sending a HTTP POST request to the /-/reload endpoint. This will also reload any configured rule files.

### Traefik
Configure each service that needs to be proxied through `traefik` with the following labels.

```yml
service-name:
  ...
  deploy:
    labels:
      traefik.enable: "true"
      # Use websecure instead of web for https configuration
      traefik.http.routers.<router-name>.entrypoints: web
      traefik.http.routers.<router-name>.rule: Host(`<domain-name>`)
      traefik.http.routers.<router-name>.service: <service-name>
      traefik.http.services.<service-name>.loadbalancer.server.port: <service-port>
      
      # The following is only for sticky sessions
      traefik.http.services.<service-name>.loadBalancer.sticky.cookie: "true"
      traefik.http.services.<service-name>.loadBalancer.sticky.cookie.name: "<random-string>"

      # Optional basic auth 
      traefik.http.routers.<router-name>.middlewares: user-auth@file
  ...
```
> Replace the `<annotations>` with correct values.