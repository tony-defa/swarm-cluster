# Docker Swarm Cluster Project Context

## Project Overview
A sophisticated Docker Swarm orchestration platform providing comprehensive application deployment, monitoring, automation, and security across a multi-node cluster. The project follows a modular, production-ready architecture with built-in high availability and scalability features.

## Core Architecture

### Directory Structure
- **`system/`** - Core infrastructure services
- **`apps/`** - Application stacks (30+ applications)
- **`mustache/`** - Dynamic stack templates
- **`jobs/`** - Background tasks and automation

### System Infrastructure (`system/`)

#### Core Services
- **Traefik** - Edge router and reverse proxy
  - HTTP/HTTPS termination
  - Load balancing and service discovery
  - SSL certificate management (Let's Encrypt, DNS challenges)
  - Metrics collection endpoint
  - Multi-provider DNS challenge support

- **Monitoring Stack** - Complete observability platform
  - **Prometheus** - Metrics collection and alerting
  - **Grafana** - Visualization and dashboards
  - **Alertmanager** - Alert routing and management
  - **Node Exporter** - Host-level metrics collection

#### Network Architecture
- **`proxy_network`** - Overlay network for Traefik and application proxying
- **`metrics_network`** - Dedicated network for monitoring services

#### Configuration Management
- **Setup Scripts** - Automated configuration creation
  - `create_traefik_data.sh` - Traefik configuration
  - `create_prometheus_data.sh` - Prometheus setup
  - `create_alertmanager_data.sh` - Alertmanager configuration
- **Environment Templates** - `example.env` files for customization

## Applications (`apps/`)

### Key Application Categories

#### Web & Content Management
- **WordPress & WordPress-HA** - CMS with optional high availability
  - Basic version: WordPress + MariaDB
  - HA version: Master-slave DB, HyperDB read/write splitting, 2+ replicas
  - Automated backup system
- **Nextcloud** - File sharing and collaboration platform
  - External database integration
  - Automated backups with maintenance mode
  - WebDAV redirect middleware

#### Databases & Storage
- **MariaDB HA** - Production database cluster
  - Master-slave replication with automated failover
  - Backup system with `--master-data=2` for restore
  - REPLICATION privilege management
  - Custom entry point scripts
- **Redis & RedisInsight** - Caching and message broker
  - Core Redis service with web interface
  - Dedicated internal network isolation

#### DevOps & Development
- **GitLab CE** - Complete DevOps platform
  - Git version control, CI/CD, issue tracking
  - LDAP integration support
  - Prometheus monitoring integration
  - Automated backup system
  - Multi-volume persistence (data, config, logs, backup)
- **Jenkins** - CI/CD server
- **n8n** - Workflow automation
- **Nexus** - Repository manager

#### Security & Utilities
- **Vaultwarden** - Password manager (Bitwarden-compatible)
- **Pihole** - Network-wide ad blocking
- **Traeik-Forward-Auth** - Authentication middleware

#### AI & Machine Learning
- **Ollama** - LLM inference server
  - GPU support (NVIDIA CUDA)
  - Model persistence and management
  - REST API interface
- **Open-WebUI** - Web frontend for Ollama
- **MetaMCP** - MCP server management

#### IoT & Home Automation
- **Mosquitto** - MQTT broker
- **Home Assistant** - Smart home hub (via mustache templates)

#### Monitoring & Logging
- **Diun** - Docker image update notifier
- **Graylog** - Log management (optional)
- **Elasticsearch** - Search and analytics

#### Media & Collaboration
- **Immich** - Self-hosted photo and video backup
- **Nextcloud** - File sharing (already categorized)
- **Music Assistant** - Music streaming and management
- **XWiki** - Collaboration platform

#### Infrastructure & Services
- **Portainer** - Docker management UI
- **Watchtower** - Container update automation
- **Nginx** - Web server/reverse proxy
- **Error Pages** - Custom error pages
- **Logrotate** - Log rotation service

### Database Infrastructure
- **MariaDB** - Single instance
- **MariaDB HA** - High-availability cluster
- **MongoDB** - NoSQL database
- **PostgreSQL** - Relational database (via mustache)

### Backup Systems
Most applications include automated backup services with:
- Configurable backup frequency
- Retention period management
- Compression and archiving
- Separate volume for backup storage

## Dynamic Stack Templating (`mustache/`)

### Architecture
- **Templates** (`.mustache` files) - Define stack structure
- **View Files** (`.view.json`) - Contain configuration data
- **Deployment Script** - Handles template generation and deployment

### Key Features
1. **Multi-environment deployments** - Different configs from same template
2. **Parameterized stacks** - Dynamic service names, ports, volumes
3. **Conditional features** - Toggle services based on configuration
4. **Flexible storage** - Automatic NFS vs local volume selection
5. **Environment-specific routing** - Custom domain and entrypoint rules

### Examples
- **WordPress Template** - Supports cron jobs, custom commands, NFS storage
- **Home Assistant Template** - Comprehensive IoT with optional Zigbee2MQTT
  - Conditional MQTT broker inclusion
  - Device constraint management
  - Multi-service backup systems

## Automation & Jobs (`jobs/`)

### Docker Prune Service (`docker-prune.yml`)
- **Image pruning** - Removes unused images (10-day retention)
- **Container pruning** - Cleans stopped containers (24-hour retention)
- **Volume pruning** - Removes dangling volumes
- **Global deployment** - Runs on all cluster nodes

## Deployment & Management

### `deploy-stack.sh` Script Features
1. **Environment file handling** - Automatic `.env` creation and parsing
2. **Secret management** - Interactive secret creation with yq integration
3. **Host directory creation** - Automatic `HOST_*` directory setup
4. **Mustache template support** - Dynamic stack generation
5. **Override file detection** - Support for custom modifications
6. **Error handling** - Comprehensive exit codes and validation

### Deployment Process
1. **Environment Configuration** - Copy and customize `example.env` files
2. **Host Directory Setup** - Create `HOST_*` paths with proper permissions
3. **Secret Creation** - Set up Docker secrets for sensitive data
4. **Network Creation** - Create required overlay networks
5. **Stack Deployment** - Use the deployment script for automated deployment

## Security Architecture

### Docker Secrets Integration
- Database passwords and credentials
- API keys and tokens
- SSL certificates and private keys
- Administrative access credentials

### Network Security
- **Overlay networks** - Isolated communication channels
- **Service constraints** - Node placement restrictions
- **Port filtering** - Controlled service exposure
- **Traefik middleware** - Basic auth, rate limiting, access control

### Access Control
- Domain-based routing and access
- SSL/TLS termination with multiple providers
- Basic authentication integration
- Rate limiting and IP whitelisting

## Storage Architecture

### Volume Management
- **Local volumes** - Node-specific storage with bind mounting
- **NFS support** - Shared storage across cluster nodes
- **Automatic provisioning** - Script-based directory creation
- **Permission management** - Docker group ownership

### Volume Types
- **Data volumes** - Application files and user data
- **Database volumes** - Dedicated persistent storage
- **Backup volumes** - Separate storage for archives
- **Configuration volumes** - Settings and customizations

## Monitoring & Observability

### Metrics Collection
- **Prometheus integration** - Standard metrics format
- **Custom exporters** - Application-specific metrics
- **Alert rules** - Configurable threshold-based alerts
- **Service discovery** - Automatic target detection

### Logging
- **Structured logging** - Consistent log format across services
- **Log rotation** - Automatic size and retention management
- **External logging** - Integration with Graylog (optional)
- **Log levels** - Configurable verbosity

### Visualization
- **Grafana dashboards** - Pre-configured monitoring views
- **Custom panels** - Application-specific metrics
- **Multi-source data** - Unified monitoring across services
- **Alert notification** - Integration with external notification systems

## High Availability & Scalability

### Horizontal Scaling
- **Replicated services** - Load balancing across instances
- **Global services** - Per-node service deployment
- **Dynamic scaling** - Runtime replica adjustment
- **Health checks** - Automatic failure detection and recovery

### Load Balancing
- **Traefik integration** - Automatic service discovery
- **Sticky sessions** - Session affinity configuration
- **Multiple entrypoints** - HTTP, HTTPS, and metrics endpoints
- **Service mesh** - Inter-service communication

### Failover Mechanisms
- **Database replication** - Automatic failover for databases
- **Service replicas** - Multiple instances for critical services
- **Health monitoring** - Continuous service availability checks
- **Graceful restarts** - Controlled service updates

## Backup & Recovery Strategies

### Built-in Backup Systems
- **Database backups** - Regular dumps with retention policies
- **Application backups** - File system archiving
- **Configuration backups** - Git-managed configs
- **Automated scheduling** - Time-based and frequency-based

### Recovery Procedures
- **Database restore** - Point-in-time recovery capabilities
- **Service restore** - Volume-based restoration
- **Configuration restore** - Git-based version control
- **Disaster recovery** - Multi-location backup strategy

## Technical Specifications

### Image Management
- **Tag management** - Specific version pinning
- **Multi-architecture** - Cross-platform support
- **Registry integration** - Private registry support
- **Image pruning** - Automated cleanup of unused images

### Resource Management
- **Memory limits** - Container resource constraints
- **CPU optimization** - Performance tuning
- **Disk I/O** - Storage performance considerations
- **Network bandwidth** - Traffic shaping and QoS

### Service Mesh Features
- **Inter-service communication** - Service discovery and routing
- **Load balancing** - Distribution across replicas
- **Health monitoring** - Service availability tracking
- **Circuit breakers** - Failure isolation and recovery

## Deployment Patterns

### Standard Stack Structure
```yaml
x-default-opts: &default-opts
  env_file:
    .env
  logging:
    options:
      max-size: "1m"
  # Optional GELF logging
  # driver: "gelf"
  # options:
  #   gelf-address: "udp://172.17.0.1:12201"

services:
  # Application services
  # Database services
  # Backup services
  # Monitoring services

networks:
  # Required overlay networks

volumes:
  # Persistent volume definitions
```

### Common Service Patterns
1. **Web Service** - Traefik labels, proxy network, health checks
2. **Database Service** - Persistent volumes, replication, backup scripts
3. **Backup Service** - Scheduled tasks, retention policies, compression
4. **Monitoring Service** - Metrics endpoints, service discovery, alerting

## Configuration Management

### Environment Variables
- **`HOST_*` paths** - Local storage directories
- **Image tags** - Version pinning for services
- **Domain names** - Routing and access control
- **Network settings** - Service connectivity
- **Backup configurations** - Frequency and retention

### Docker Secrets
- **Database credentials** - Usernames and passwords
- **API keys** - External service authentication
- **SSL certificates** - TLS termination
- **Administrative access** - Management interfaces

### Network Configuration
- **Overlay networks** - Multi-node communication
- **Port mapping** - External access control
- **Service discovery** - Internal service communication
- **Network policies** - Traffic isolation and security

## Maintenance & Operations

### Regular Tasks
- **Image updates** - Container image management
- **Security patches** - Vulnerability management
- **Performance monitoring** - Resource optimization
- **Log management** - Storage and retention
- **Backup verification** - Recovery testing

### Troubleshooting
- **Service logs** - Debug and diagnostic information
- **Network connectivity** - Service communication issues
- **Volume mounts** - Storage and permission problems
- **Resource limits** - Performance bottlenecks
- **Secret management** - Authentication and authorization

## Integration Points

### External Systems
- **Monitoring** - Prometheus, Grafana, Alertmanager
- **Logging** - Graylog, ELK stack (optional)
- **Backup** - NFS, cloud storage integration
- **DNS** - Multiple provider support for SSL certificates
- **Authentication** - LDAP, OAuth, basic auth

### Service Dependencies
- **Database** - External MariaDB/PostgreSQL support
- **Caching** - Redis for performance optimization
- **Message Queue** - MQTT for IoT integration
- **Storage** - NFS for shared file systems
- **Load Balancing** - Traefik for service proxying

## Best Practices

### Security
- Use Docker secrets for sensitive data
- Implement network isolation with overlay networks
- Regular security updates and patching
- Access control and authentication
- SSL/TLS encryption for all external communications

### Performance
- Resource limits and quotas
- Efficient storage management
- Network optimization
- Monitoring and alerting
- Regular performance tuning

### Reliability
- High availability with replication
- Automated backups and disaster recovery
- Health checks and monitoring
- Graceful degradation
- Comprehensive logging and diagnostics

This context file provides a comprehensive overview of the Docker Swarm cluster project architecture, deployment patterns, and operational considerations. It serves as a foundational reference for understanding, managing, and extending the platform.