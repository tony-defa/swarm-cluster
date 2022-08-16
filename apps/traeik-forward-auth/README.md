# Traefik forward auth

A minimal forward authentication service that provides OAuth/SSO login and authentication for the traefik reverse proxy/load balancer.

### `forward-auth.yml`
Contains only the traefik forward auth service.

## Perquisites
### Storage
A centralized storage solution is not required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

> It is recommended to copy the original `forward-auth.yml` to a named `<name>-forward-auth.yml` version.
> ```sh
> $ cp forward-auth.yml customname-forward-auth.yml
> ```
> Rules can be defined in the command section of the compose file.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
Configure each service that needs to use this middleware by adding the following label
```yml
traefik.http.routers.<router-name>.middlewares: oauth@docker
```

Alternatively you can add the middleware to an entrypoint
```sh
--entryPoints.<entrypoint-name>.http.middlewares=oauth@docker
```

> Replace the `<annotations>` with correct values.