# nginx

nginx ("engine x") is an HTTP web server, reverse proxy, content cache, load balancer, TCP/UDP proxy server, and mail proxy server.

## `nginx.yml`
Contains the nginx web server, that is primarily intended to serve static files. There is also a script, that backups the files.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
Copy the `config/example.conf` to create your custom nginx configuration.

```sh
$ cp config/example.conf config/.conf
```

Edit the newly created `.conf` file to fit your needs. See [nginx Documentation](https://nginx.org/en/docs/) for further information.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
No notes