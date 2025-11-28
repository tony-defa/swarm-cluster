# Contributing to Docker Swarm Cluster

Thank you for your interest in contributing to this Docker Swarm cluster project! This guide will help you understand the project structure, stack requirements, and contribution guidelines.

## Project Structure Overview

The project is organized into four main categories:

```
├── system/           # Core infrastructure services
├── apps/            # Application stacks  
├── mustache/        # Dynamic stack templates
└── jobs/           # Background tasks and automation
```

### Directory Purpose

- **`system/`** - Core services that the entire cluster depends on (Traefik, monitoring, etc.)
- **`apps/`** - End-user applications and services
- **`mustache/`** - Template-based stacks for multi-environment deployments
- **`jobs/`** - Automated tasks and maintenance jobs

## Stack Requirements and Structure

### Every Stack Must Include

1. **README.md** - Comprehensive documentation (see structure below)
2. **Stack file** - Docker Compose file (`.yml` or `.mustache`)
3. **example.env** - Environment variable template
4. **Configuration files** - Any required configuration templates

### Stack File Structure

Every stack should follow this preferred structure with sidecar services where applicable:

```yaml
x-default-opts: &default-opts
  env_file:
    .env
  logging:
    options:
      max-size: "1m"
  # Optional: GELF logging driver
  # driver: "gelf"
  # options:
  #   gelf-address: "udp://172.17.0.1:12201"

services:
  # Main application service
  main-service:
    <<: *default-opts
    image: registry/app:latest
    networks:
      - proxy_network
      - app_network
    volumes:
      - data:/app/data
    environment:
      # Environment variables
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      labels:
        traefik.enable: "true"
        traefik.http.routers.app.rule: Host(`${DOMAIN}`)
        traefik.http.routers.app.service: app
        traefik.http.services.app.loadbalancer.server.port: 8080

  # Backup service (if applicable)
  backup:
    <<: *default-opts
    image: alpine:latest
    volumes:
      - data:/data
      - backup:/backup
    command: 
      - sh
      - -c
      - |
        while true; do
          # Backup logic here
          # Remove backups older than retention period
          find /backup -type f -mtime +${RETENTION_DAYS:-14} -delete
          sleep ${BACKUP_FREQUENCY:-24h}
        done
    deploy:
      restart_policy:
        condition: on-failure
        delay: 600s

  # Monitoring/Metrics service (if applicable)
  metrics:
    <<: *default-opts
    image: prometheus/main-service-exporter:latest
    networks:
      - app_network
    deploy:
      mode: global
      restart_policy:
        condition: on-failure

networks:
  proxy_network:
    external: true
    
  app_network:
    driver: overlay

volumes:
  data:
    driver: local
    driver_opts:
      device: ${HOST_DATA_PATH}
      type: none
      o: bind

  backup:
    driver: local
    driver_opts:
      device: ${HOST_BACKUP_PATH}
      type: none
      o: bind
```

### Required Sidecar Services

**Backup Services** should be included for:
- Databases (regular dumps)
- File-based applications (compressed archives)

**Monitoring Services** should include:
- Metrics exporters for applications
- Health check endpoints
- Resource usage monitoring

## README.md Structure

Every stack README must follow this exact structure:

```markdown
# Service Name

Brief description of the service and its purpose.

### `stack-file.yml`
Brief explanation of what this file contains and its purpose.

## Prerequisites
### Storage
Description of storage requirements.

### Service dependencies
List of mandatory stacks that must be deployed first.

### Create pre-configured data folder
Instructions for copying configuration files (if applicable).

### Create docker secrets
List of required Docker secrets and their purposes.

### Create network
Instructions for creating required networks.

## Other notes
Any additional configuration details, known issues, or special considerations.
```

## Configuration File Management

### Configuration Files Pattern

Many stacks require configuration files that follow this pattern:

1. **Template file**: `example.conf` (provided in the repository)
2. **Runtime file**: `.conf` (copied from template and customized; ignored in `.gitignore`)

**Example workflow:**
```bash
# Copy template
cp example.conf .conf

# Edit configuration
vi .conf

# Deploy stack
docker stack deploy -c stack-file.yml stack-name
```

### Configuration File Locations

Place configuration files in appropriate subdirectories:
- **`config/`** - Application configuration
- **`entrypoint.d/`** - Startup scripts (for database services)
- **Root level** - Main configuration files

### Common Configuration Patterns

**Database Configuration:**
```bash
# Copy database configuration
cp example.db.conf .db.conf

# Edit configuration file
sed -i 's/localhost/localhost:3306/' .db.conf
```

**Application Configuration:**
```bash
# Copy application config
cp config/example.json config/.json

# Customize configuration
jq '.port = 8080' config/.json > config/.json.tmp && mv config/.json.tmp config/.json
```

## Environment Files (`example.env`)

### Structure Requirements

Every `example.env` file must include:

```bash
# Host volume paths
HOST_DATA_PATH=/cluster/service_data
HOST_CONFIG_PATH=/cluster/service_config
HOST_BACKUP_PATH=/cluster/service_backup

# Image tags
SERVICE_TAG=latest
DEPENDENCY_TAG=latest

# Proxy configuration
ENTRYPOINT=websecure
DOMAIN=service.host.local

# Service-specific configuration
DB_CONNECTION_STRING=postgresql://user:pass@db:5432/dbname
API_KEY=
DEBUG_MODE=false

# Backup configuration
BACKUP_FREQUENCY=24h
RETENTION_DAYS=14
```

### Environment Variable Naming Convention

- **`HOST_*`** - Host volume mount paths
- **`*_TAG`** - Docker image tags
- **`DOMAIN`** - Service domain name, can differ if multiple services are hosted
- **`ENTRYPOINT`** - Traefik entrypoint (web/websecure), must match the number of `DOMAIN`s

## Network Requirements

### Required Networks

Most stacks require these standard networks:
- **`proxy_network`** - For Traefik integration (external)
- **`app_network`** - Internal service communication (overlay)

### Network Creation

Networks should be created once at the cluster level:
```bash
docker network create -d overlay proxy_network
docker network create -d overlay metrics_network
```

## Volume and Storage Patterns

### Volume Mount Structure

```yaml
volumes:
  data:
    driver: local
    driver_opts:
      device: ${HOST_DATA_PATH}
      type: none
      o: bind
```

### Storage Paths

Define clear storage paths in `example.env`:
- **Data**: `/cluster/service_data/data`
- **Config**: `/cluster/service_data/config` 
- **Logs**: `/cluster/service_data/logs`
- **Backup**: `/cluster/service_data/backup`

## Docker Secrets Management

### Secret Requirements

List all required secrets in README with clear instructions:

```markdown
### Create docker secrets
Create the following docker secrets:

- `secret_name`: Purpose of the secret
- `another_secret`: Description of its use

Create secrets using:
```bash
printf "secret_value" | docker secret create secret_name -
```
```

### Best Practices for Secrets

- Store secrets in Docker Secret store
- Reference secrets via files in containers
- Never hardcode secrets in configuration files
- Document secret purposes clearly

## Mustache Template Guidelines

### Template Structure

For mustache-based stacks in `mustache/`:

1. **Template file** (`*.mustache`): Define stack structure
2. **View file** (`.view.json`): Configuration data
3. **Env file** (`.env`): Environment-specific settings

### Template Requirements

- Use conditional sections for optional features
- Include all service variations in one template
- Provide clear documentation of available options
- Include example view files with comments

## Testing and Validation

### Pre-Deployment Checklist

Before submitting a new stack:

1. ✅ **README follows required structure**
2. ✅ **All required files present** (README, stack file, example.env)
3. ✅ **Configuration files properly templated**
4. ✅ **Networks correctly defined**
5. ✅ **Volumes properly configured**
6. ✅ **Secrets documented**
7. ✅ **Backup services included** (for data-heavy apps)
8. ✅ **Monitoring integration** (where applicable)
9. ✅ **Example environment variables complete**
10. ✅ **Stack deploys successfully** in test environment

## Contribution Workflow

### Pull Request Process

1. **Fork the repository**
2. **Create feature branch** for your stack
3. **Follow structure guidelines** above
4. **Test thoroughly** in development environment
5. **Update README.md** with complete documentation
6. **Submit pull request** with detailed description
7. **Address feedback** and merge

### Code Style Guidelines

- **YAML formatting**: Use consistent indentation (2 spaces)
- **Comments**: Explain complex configurations
- **Naming**: Use descriptive service and volume names
- **Version pinning**: Use specific image tags
- **Resource limits**: Set appropriate memory/CPU limits

## Maintenance Guidelines

### Updating Existing Stacks

1. **Check for new versions** of base images
2. **Update `example.env`** with new tags
3. **Test deployment** with new versions
4. **Update documentation** if breaking changes
5. **Deprecate old versions** with clear migration guide

### Adding New Applications

1. **Research community needs**
2. **Check for existing implementations**
3. **Follow established patterns**
4. **Include backup/monitoring** where applicable
5. **Document thoroughly** with examples
6. **Test in multiple environments**

## Additional Resources

- [Docker Swarm documentation](https://docs.docker.com/engine/swarm/)
- [Traefik documentation](https://doc.traefik.io/traefik/)
- [Prometheus documentation](https://prometheus.io/docs/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/)

Thank you for contributing to this project! Your work helps make the Docker Swarm cluster more robust and useful for the community.