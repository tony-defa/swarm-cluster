# Jenkins

Jenkins is an open source automation server which enables developers around the world to reliably build, test, and deploy their software.

### `jenkins.yml`
Contains the jenkins application and also provides a backup service running on an alpine image.

## Prerequisites
### Storage
A centralized storage solution is required.

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
### First login
The initial admin password can be found either in the log of the running container 

```sh 
$ docker service logs <stack_name>_jenkins
```
or in the configured volume, in the `secrets/initialAdminPassword` file.

### Backup
The backup service securely backs up the configuration all files (`*.xml`) in the jenkins home directory as well as jobs, builds and specific plugin versions into a compressed tar archive. Old archives are deleted automatically after the amount of days specified in the environment variable `RETENTION_DAYS`. 