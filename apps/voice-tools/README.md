# Voice Tools

AI-powered voice services stack featuring Piper (Text-to-Speech) and Faster-Whisper (Speech-to-Text). Both services use the Wyoming protocol and connect via the `macvlan_swarm` network for direct Home Assistant integration.

### `voice-tools.yml`

This stack file defines two services: `piper` (TTS) and `faster-whisper` (STT). Each service runs in its own container with dedicated volumes for model storage and configurable resource limits suitable for hardware w/o GPU.

## Prerequisites

### Storage

Create the host directories for persistent data:

```bash
mkdir -p /cluster/voice-tools/piper
mkdir -p /cluster/voice-tools/whisper
```

### Service dependencies

Mandatory stacks:
- `macvlan_swarm` overlay network must exist

### Create pre-configured data folder

No pre-configured data folder available. The required directories will be created automatically based on the HOST paths defined in the `.env` file.

### Create docker secrets

No docker secrets are required for this stack.

### Create network
No network needs to be created.

## Other notes

### Piper TTS

Piper uses the Wyoming protocol on port 10200. Available voice models are listed at: https://huggingface.co/rhasspy/piper-voices/tree/main

Recommended for Raspberry Pi:
- `en_US-lessac-medium` (default)
- `en_US-lessac-small` (faster, lower quality)
- `en_US-lessac-large` (slower, higher quality)

Key configuration in `.env`:
- `PIPER_VOICE`: Model name (without `.onnx`)
- `PIPER_PROCS`: Number of CPU cores (default 1)
- `PIPER_LENGTH`, `PIPER_NOISE`, `PIPER_SPEAKER`: TTS parameters

### Faster-Whisper STT

Faster-Whisper uses CTranslate2 for optimized CPU performance. Quantized models (ending in `-int8`) are strongly recommended for Raspberry Pi.

Model options (speed → accuracy):
`tiny-int8` → `base-int8` (default) → `small-int8` → `medium-int8` → `large-v3-int8`

Key configuration in `.env`:
- `WHISPER_MODEL`: Model name (e.g., `base-int8`, `tiny-int8`)
- `WHISPER_BEAM`: Beam size (higher = more accurate but slower)
- `WHISPER_LANG`: Default language code (e.g., `en`, `de`, `fr`)

Uses Wyoming protocol on port 10300.

### Performance Tuning

Adjust resource limits in `.env` based on your Pi model:

| Pi Model | RAM | Recommended Limits |
|----------|-----|-------------------|
| Pi 3B+ | 1GB | `MEM_LIMIT=1g`, `CPU_LIMIT=1.0` |
| Pi 4 (2-4GB) | 2-4GB | `MEM_LIMIT=2g`, `CPU_LIMIT=2.0` |
| Pi 4 (8GB) | 8GB | `MEM_LIMIT=4g`, `CPU_LIMIT=4.0` |
| Pi 5 (4GB) | 4GB | `MEM_LIMIT=3g`, `CPU_LIMIT=3.0` |
| Pi 5 (8GB) | 8GB | `MEM_LIMIT=5g`, `CPU_LIMIT=4.0` |

Monitor resource usage:
```bash
docker stats voice-tools_piper voice-tools_faster-whisper
```

### Model Download

Models are downloaded automatically on first startup (may take several minutes).