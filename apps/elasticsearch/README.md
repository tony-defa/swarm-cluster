# Elasticsearch

Elasticsearch is a search engine based on the Lucene library. It provides a distributed, multitenant-capable full-text search engine with an HTTP web interface and schema-free JSON documents and comes additionally with Kibana a source-available data visualization dashboard software for Elasticsearch.

### `elasticsearch.yml`
Contains a single elasticsearch node and kibana as a separate service.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
There are no dependencies.

### Create pre-configured data folder
No pre-configured data folder available.

### Create docker secrets
No docker secrets are required.

### Create network
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create --attachable -d overlay elastic_network
```

## Other notes
This is a very basic implementation of elasticsearch and kibana and it should not be considered production ready.