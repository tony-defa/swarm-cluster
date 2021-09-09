# Graylog App

Graylog is a leading centralized log management solution for capturing, storing, and enabling real-time analysis of terabytes of machine data.

### `graylog.yml`
Contains graylog and the required backend for running properly.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

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
      gelf-address: "udp://127.0.0.1:12201"
  ...
```