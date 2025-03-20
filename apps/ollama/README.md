# Ollama

Ollama is a high-performance machine learning inference server that allows you to run large language models efficiently.

### `ollama.yml`
Contains the core Ollama service with GPU support.

### `open-webui.yml`
Contains the Open-WebUI frontend and LiteLLM API interface.

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

### Usage
- Ollama API is accessible at: `http://${OLLAMA_DOMAIN}` or `http://localhost:${OLLAMA_WEBAPI_PORT}`
- Open-WebUI is accessible at: `http://${WEBUI_DOMAIN}`