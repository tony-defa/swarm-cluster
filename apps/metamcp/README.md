# MetaMCP

MetaMCP is an open-source platform for building and deploying Model Context Protocol (MCP) servers. It provides a web interface for creating, testing, and managing MCP servers that can be integrated with AI models like Claude Desktop.

### `metamcp.yml`
Contains the MetaMCP application and PostgreSQL database.

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
### SSE Support
MetaMCP can use Server-Sent Events (SSE) for real-time communication. The stack is configured with Traefik but it is not configured to properly handle SSE connections with appropriate timeouts and buffering settings. This could be added in a future update.

### Authentication
By default, MetaMCP uses basic authentication. For production deployments, configure the `BETTER_AUTH_SECRET` environment variable with a strong secret key.

### OIDC Authentication
Optional OpenID Connect authentication can be enabled by configuring the OIDC environment variables in the `.env` file.