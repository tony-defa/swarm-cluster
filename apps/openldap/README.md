# OpenLDAP

OpenLDAP Software is an open source implementation of the Lightweight Directory Access Protocol. 

### `openldap.yml`
Contains OpenLDAP, a WebUI, Self-Service-Password (SSP) a UI that permits password changes and data backup from [osixia](https://hub.docker.com/u/osixia). 

## Perquisites
### Storage
A centralized storage solution is not required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
Copy the `example.ssp.conf.php` to create your custom SSP configuration.

```sh
$ cp example.ssp.conf.php .ssp.conf.php
```

Edit the newly created `.ssp.conf.php` file to fit your needs. See [Self-Service-Password Documentation](https://self-service-password.readthedocs.io/en/latest/index.html) for further information.

### Create docker secrets
Create the following docker secrets to configure the startup passwords.

- `ldap_admin_password`: The password for the admin user
- `ldap_config_password`: The password for the config user
- `ldap_ro_user_password`: The password for a read-only user

> Set the `LDAP_READONLY_USER` variable to false, if there should'n be a read-only user. In that case 
the `ldap_ro_user_password` secret can be an empty or dummy value.

### Create network
No network needs to be created.

## Other notes

### TLS over traefik
The current configuration uses TLS termination at the traefik proxy.

### Backup
OpenLDAP data and config are backed up every day a 4 AM and kept for 10 days.

### Restore Backup
To restore a Backup move the files to restore into the backup volume and use the `slapd-restore` bin 
that is found within the backup container. Execute the following from within the container:

```sh
$ slapd-restore 1 <datetime>-data.gz
$ slapd-restore 0 <datetime>-config.gz
```
