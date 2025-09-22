# Redis

Redis is an open-source in-memory storage, used as a distributed, in-memory key–value database, cache and message broker, with optional durability. Also comes with RedisInsight that is a visual tool that provides capabilities to design, develop and optimize your Redis application. Query, analyse and interact with your Redis data.

### `redis.yml`
Contains a single Redis instance and RedisInsight as a separate service.

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
Create a public overlay network for applications to use to connect to the database.

```sh
$ docker network create --attachable -d overlay redis_network
```

## Other notes
This is a very basic implementation of Redis and RedisInsight and it should not be considered production ready.