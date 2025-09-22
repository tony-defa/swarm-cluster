# MongoDB

MongoDB is a document-oriented NoSQL database used for high volume data storage. Instead of using tables and rows as in the traditional relational databases, MongoDB makes use of collections and documents. Documents consist of key-value pairs which are the basic unit of data in MongoDB. Collections contain sets of documents and function which is the equivalent of relational database tables. MongoDB is a distributed database at its core, so high availability, horizontal scaling, and geographic distribution are built in and easy to use.

### `mongodb.yml`
Contains the database, mongo-express the web based admin interface and an exporter for prometheus.

## Prerequisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
Create the following docker secrets to configure the database passwords.

- `mongodb_root_password`: The password for the root user
- `mongodb_db_user`: The database name
- `mongodb_db_password`: The database non root user
- `mongodb_db_name`: The password associated to the `mongodb_db_user` secret

Use these secrets to stacks or services that need to connect to this database.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create --attachable -d overlay mongo_network
```
> The `--attachable` flag is optional. It allows you to attach other services to this network.

## Other notes
### Web based admin interface
The web based admin interfaces default user is `admin` and the password is the value of the `mongodb_root_password` secret.
 
### Prometheus exporter
Use the following scraping configuration for prometheus:

```yml
scrape_configs:
  ...
  - job_name: 'mongodb'
    metrics_path: '/metrics'
    scrape_interval: 30s
    static_configs:
    - targets: ['exporter:9216']
```

