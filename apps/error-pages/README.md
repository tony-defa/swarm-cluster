# WhoAmI

Tiny Go webserver that prints os information and HTTP request to output.

### `whoami.yml`
Contains only the whoami service.

## Perquisites
### Storage
A centralized storage solution is not required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
The error pages are automatically shown for each caught router rule that does not point to an existing service.

Additionally you can add the middleware to an entrypoint, so that all services will show the error pages, when an erroneous status code is returned.
```sh
--entryPoints.<entrypoint-name>.http.middlewares=error-pages-middleware@docker
```

or configure single services that need to use this middleware by adding the following label
```yml
traefik.http.routers.<router-name>.middlewares: error-pages-middleware@docker
```

> Replace the `<annotations>` with correct values.