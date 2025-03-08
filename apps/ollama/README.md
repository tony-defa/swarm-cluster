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

Optional stacks:
- `system/monitoring.yml`

### Create pre-configured data folder
No pre-configured data folder available. The required directories will be created automatically based on the HOST paths defined in the .env file.

### Create docker secrets
No docker secrets are required.

### Create network
The `ollama.yml` stack automatically creates an `ollama_network` that is used by the `open-webui.yml` stack.

## Deployment
1. Copy the environment file:
```sh
$ cp example.env .env
```

2. Edit the `.env` file to configure:
   - Host volume paths
   - GPU settings
   - Port mappings
   - Domain names

3. Create the required host directories:
```sh
$ cat .env | grep "^HOST_[A-Z]" | cut -d'=' -f2 | xargs sudo mkdir -p
$ cat .env | grep "^HOST_[A-Z]" | cut -d'=' -f2 | xargs sudo chown -R :docker
```

4. Deploy the core Ollama service:
```sh
$ env -i $(cat .env | grep "^[A-Z]" | xargs) docker stack deploy -c ollama.yml ollama
```

5. Deploy the Open-WebUI services:
```sh
$ env -i $(cat .env | grep "^[A-Z]" | xargs) docker stack deploy -c open-webui.yml open-webui
```

## Usage
- Ollama API is accessible at: `http://${DOMAIN}:${OLLAMA_WEBAPI_PORT}`
- Open-WebUI is accessible at: `http://${WEBUI_DOMAIN}:${OLLAMA_WEBUI_PORT}`

## Notes
- GPU support requires Docker with appropriate drivers installed on the host
- Models are downloaded on first use and stored in the persistent volume
- The Open-WebUI stack depends on the Ollama stack, so deploy Ollama first