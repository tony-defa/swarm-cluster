# Ollama

Ollama is a high-performance machine learning inference server that allows you to run large language models efficiently.

### `ollama.yml`
Contains the core Ollama service with GPU support.

### `open-webui.yml`
Contains the Open-WebUI frontend and the mcpo service for managing multiple MCP servers.

## Prerequisites
### Storage
A centralized storage solution is required for persistent model storage.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
No pre-configured data folder available. The required directories will be created automatically based on the HOST paths defined in the .env file.

### Create docker secrets
No docker secrets are required.

### Create network
The `ollama.yml` stack automatically creates an `ollama_network` that is used by the `open-webui.yml` stack.

## Other notes
- GPU support requires Docker with appropriate drivers installed on the host and the `default-runtime` set to `nvidia` in the docker `/etc/docker/daemon.json` file.
- Models are downloaded on first use and stored in the persistent volume
- The Open-WebUI stack depends on the Ollama stack, so deploy Ollama first. The Ollama stack should be called `ollama`. 

### MCP Servers Configuration

The configuration for MCP servers is managed via a Docker config named `mcp_config` defined in the `open-webui.yml` file. The source file for this config is `./config/example.json`.

To configure your MCP servers, copy the `./config/example.json` to `./config/.json`, edit the new file and add your server definitions within the `mcpServers` array.

Example `config/.json`:

```json
{
  "mcpServers": [
    {
      "name": "my-mcp-server",
      "url": "http://localhost:8000"
    }
  ]
}
```

### Usage
- Ollama API is accessible at: `http://${OLLAMA_DOMAIN}` or `http://localhost:${OLLAMA_WEBAPI_PORT}`
- Open-WebUI is accessible at: `http://${WEBUI_DOMAIN}`