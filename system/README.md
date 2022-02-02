# System services

Traefik is an open-source Edge Router that makes publishing your services a fun and easy experience. It receives requests on behalf of your system and finds out which components are responsible for handling them.

Portainer enables centralized configuration, management and security of Kubernetes and Docker environments, allowing you to deliver ‘Containers-as-a-Service’ to your users quickly, easily and securely.

### `traefik.yml`
Contains traefik configured for execution with docker swarm.

### `portainer.yml`
Contains portainer itself and the agent that runs on every node.

## Perquisites
### Storage
A centralized storage solution is required for the following stacks:
- `traefik.yml`
- `portainer.yml`

### Service dependencies
`traefik.yml` requires the following services to run:
- `apps/prometheus/prometheus.yml`

`portainer.yml` requires the following services to run:
- `traefik.yml`

### Create pre-configured data folder
For traefik to work properly some configuration steps are necessary. Run the following commands to complete this step:

```sh
$ chmod +x ./create_traefik_data.sh
$ sudo ./create_traefik_data.sh
```

> Use the `sudo` command, if the path of the configured `HOST_TRAEFIK_DATA` variable does not reside in your home directory. Omit `sudo` otherwise.
> For NFS configuration: Edit the script at the end and use `nobody:nogroup` as owner for the created directory with the `chown` command.

To create a basic auth account use the following commands (optional)

```sh
$ sudo apt install apache2-utils
$ htpasswd -nb <user> <password> | sudo tee "$(cat .env | grep "HOST_TRAEFIK_PATH" | cut -d'=' -f2)/users.txt"
```
> Replace the `<user>` and `<password>`placeholders.
> Use `sudo` command as explained above.

### Create docker secrets
No docker secrets are required.

### Create network
Create a public overlay network for the proxy (traefik).

```sh
$ docker network create -d overlay public_network
```

## Other notes
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