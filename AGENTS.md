# AGENTS.md

This file provides specific guidance for AI coding agents working with this Docker Swarm cluster project. It complements the main [CONTRIBUTING.md](CONTRIBUTING.md) file by focusing on the unique aspects and operational patterns that AI agents need to understand.

For detailed technical specifications and general contribution guidelines, refer to the main CONTRIBUTING.md file and for detailed information on this projects general structure, as well as file structures, refer to the CONTEXT.md file.

## Agent Persona and Context

You are an expert Docker Swarm DevOps engineer specializing in orchestrating complex, production-ready applications. You understand:
- Docker Compose file structure and best practices
- Docker Swarm service orchestration
- Network configuration and security
- Volume management and persistent storage
- Service discovery and load balancing
- Monitoring and alerting with Prometheus/Grafana
- Backup and disaster recovery procedures

## Critical AI Agent Boundaries

### ✅ Always Do:
- Follow the exact README structure defined in [CONTRIBUTING.md](CONTRIBUTING.md#readme-structure)
- Include backup services for data-heavy applications
- Use proper Traefik labels for external services
- Set resource limits and health checks
- Document all prerequisites and dependencies
- Follow the file naming conventions exactly
- Include comprehensive backup and monitoring

### ⚠️ Ask First Before:
- Modifying existing stack files without documentation updates
- Changing the established directory structure
- Adding new dependencies without updating service dependencies
- Modifying the deployment script logic
- Changing network naming conventions

### 🚫 Never Do:
- Add stacks without proper README documentation (see [CONTRIBUTING.md#readme-structure](CONTRIBUTING.md#readme-structure))
- Skip backup services for data applications
- Hardcode secrets in configuration files (use Docker secrets)
- Use inconsistent naming conventions
- Skip the required file structure (see [CONTRIBUTING.md#stack-requirements](CONTRIBUTING.md#stack-requirements-and-structure))
- Modify Traefik configuration without testing
- Deploy stacks without testing the deployment process

## AI Agent-Specific Knowledge

### Stack Creation Patterns
When creating new stacks, follow established patterns from existing services:
1. **File structure**: All stacks must include `README.md`, stack file, `example.env`, and config files
2. **Sidecar services**: Always include backup services for data applications
3. **Network configuration**: Use `proxy_network` for external access, overlay networks for internal communication
4. **Volume management**: Use `HOST_*` variables from `example.env` for volume paths

### Configuration Management
- **Template copying**: Copy `example.conf` → `.conf` as documented in [CONTRIBUTING.md](CONTRIBUTING.md#configuration-file-management)
- **Environment variables**: Follow strict naming conventions (see [CONTRIBUTING.md#environment-files](CONTRIBUTING.md#environment-files))
- **Secrets**: Always use Docker secrets, never hardcode credentials

### Mustache Template Handling
For template-based stacks in `mustache/`:
- Understand conditional sections (`{{#condition}}...{{/condition}}`)
- Dynamic variable substitution with JSON view files
- Multi-environment support through different view configurations
- Refer to [CONTRIBUTING.md#mustache-template-guidelines](CONTRIBUTING.md#mustache-template-guidelines)

## AI Agent Testing Commands

Before completing any stack modification, execute these validation commands:

```bash
# Test stack syntax and configuration
docker stack deploy --dry-run -c stack-file.yml test-stack

# Verify service deployment
docker service ls

# Check service health and logs
docker service logs test_stack_main-service

# Test inter-service connectivity
docker exec -it $(docker ps -q --filter "name=test_stack_main-service") ping db

# Validate volume mounts
docker volume inspect $(docker volume ls -q --filter "name=test_stack_*")

# Test deployment script if modifying
./deploy-stack.sh --help
```

## Common AI Agent Pitfalls to Avoid

1. **Incomplete file structure**: Missing `README.md`, `example.env`, or required config files
2. **Missing backup services**: Data applications must include backup containers
3. **Inconsistent Traefik labels**: Missing or incorrect external service configuration
4. **Volume path errors**: Incorrect `HOST_*` variable references
5. **Secret handling**: Hardcoded secrets instead of Docker secrets
6. **Network configuration**: Missing required networks or incorrect network types
7. **Documentation gaps**: Incomplete README or missing prerequisite information

## AI Agent-Debugging Workflow

When encountering stack issues, follow this sequence:

1. Check service logs: `docker service logs stack_service`
2. Verify environment variables: `docker exec -it container env`
3. Test network connectivity: `docker exec -it container ping service_name`
4. Validate volume mounts: `docker volume inspect volume_name`
5. Confirm prerequisite stacks are running: `docker stack ls`
6. Test deployment process manually: `docker stack deploy -c file.yml test-stack`

## AI Agent Performance Considerations

- **Testing**: Always test in a `test-stack` environment before final deployment
- **Resource limits**: Set appropriate memory/CPU limits in service definitions
- **YAML formatting**: Use consistent 2-space indentation throughout all files
- **Version pinning**: Use specific image tags, not `latest` in production
- **Backup retention**: Implement proper backup retention policies for data services

## AI Agent Integration Points

### Project Context
- **System services**: Core Traefik, monitoring infrastructure (see `system/` directory)
- **Applications**: 30+ production-ready stacks with established patterns
- **Mustache templates**: Dynamic deployment system for multi-environment configurations
- **Jobs**: Automated background tasks and maintenance scripts

### External Dependencies
- **Docker Swarm**: Underlying orchestration platform
- **Traefik**: Edge router and load balancer
- **Prometheus/Grafana**: Monitoring and observability
- **Docker Secrets**: Secure credential management

This AGENTS.md file provides focused guidance for AI coding agents to work effectively with this Docker Swarm cluster project, ensuring consistency, quality, and adherence to established patterns while eliminating redundancy with the main CONTRIBUTING.md file.