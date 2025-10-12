# Stable Diffusion WebUI Forge Neo - GPU Cloud Docker

Docker image for **Stable Diffusion WebUI Forge Neo** optimized for GPU cloud platforms (RunPod, Vast.ai) with network volume support.

**Docker Hub:** `davidahlstroem/forge-webui-cloud:latest`

**Forge Neo** is an actively maintained fork with optimizations and support for latest models (Flux Kontext, Wan 2.2, Qwen-Image, etc).

The container automatically starts all services when deployed to GPU cloud platforms

## What's Included

- **CUDA 12.4.1** base (Ubuntu 22.04)
- **Python 3.11** with pip
- **PyTorch 2.5.1** + torchvision (CUDA 12.4 optimized)
- **xFormers 0.0.28.post3** for memory efficiency
- **Jupyter Lab** with extensions
- **Git, curl, wget** and build tools

## How It Works

### First Run (~10-15 minutes)
- Installs **Stable Diffusion WebUI Forge Neo** to `/workspace/stable-diffusion-webui-forge`
- Installs all Forge dependencies
- Creates model directories in `/workspace/models/`
- Starts Forge WebUI on port 7860 (with API enabled)
- Starts Jupyter Lab on port 8888

### Subsequent Runs (~2-3 minutes)
- Detects existing Forge installation in `/workspace/`
- Optionally updates via `git pull`
- Starts services immediately

## Directory Structure

```
/workspace/                                   # Network volume (persistent)
├── stable-diffusion-webui-forge/             # Forge WebUI installation
├── models/                                   # Model storage
│   ├── checkpoints/
│   ├── loras/
│   ├── vae/
│   └── ...
├── setup.sh                                  # Optional custom setup script
├── start.sh                                  # Main startup script (from image)
├── forge.log                                 # Forge startup/runtime logs
└── jupyter.log                               # Jupyter logs
```

## Custom Setup Script

Place your setup script at `/workspace/setup.sh` and it runs automatically after all services start.

**Example `/workspace/setup.sh`:**
```bash
#!/bin/bash
set -e

# Download a model
cd /workspace/models/checkpoints
wget https://example.com/model.safetensors

# Clone extensions
cd /workspace/stable-diffusion-webui-forge/extensions
git clone https://github.com/your-username/your-extension.git

echo "Custom setup complete!"
```

## Exposed Ports

- **7860** - Stable Diffusion WebUI Forge (web interface + API)
- **8888** - Jupyter Lab (no authentication)

## Troubleshooting

### Check Logs
```bash
# In terminal or Jupyter
cat /workspace/forge.log        # Forge startup/runtime logs
cat /workspace/jupyter.log      # Jupyter logs
```

### First Startup Taking Long?
- First run installs Forge (~10-15 min for dependencies)
- Compiling CUDA kernels on first GPU use (~2-3 min)
- Subsequent starts are much faster with network volume

### Container Crashes?
- Ensure `/workspace` is mounted (network volume)
- Check disk space (need 30-50GB minimum)
- GPU must support CUDA 12.4

### Forge Won't Start?
- Check `/workspace/forge.log` for errors
- Verify GPU is detected: `nvidia-smi`
- Try accessing Jupyter (port 8888) first to debug


## Technical Details

**Base Image:** `nvidia/cuda:12.4.1-base-ubuntu22.04`  
**Image Size:** ~3.5GB (compressed)  
**Forge Version:** Neo (actively maintained fork)  
**Forge Repo:** [sd-webui-forge-classic/neo](https://github.com/Haoming02/sd-webui-forge-classic/tree/neo)  
**Forge Install:** Runtime (first boot only)  
**Auto-publishes:** Every push to master branch via GitHub Actions


**Repository:** [github.com/davidahlstroem/forge-webui-cloud](https://github.com/davidahlstroem/forge-webui-cloud)  
**Docker Hub:** [hub.docker.com/r/davidahlstroem/forge-webui-cloud](https://hub.docker.com/r/davidahlstroem/forge-webui-cloud)
