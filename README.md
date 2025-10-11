# Stable Diffusion WebUI Forge - GPU Cloud Docker

Docker image for **Stable Diffusion WebUI Forge** optimized for GPU cloud platforms with automatic workspace setup.

**Docker Hub:** `<your-username>/forge-webui-cloud:latest`

The container automatically starts all services when deployed to GPU cloud platforms

## 📦 What's Included

- **CUDA 12.4.1** + PyTorch 2.4.1 + xFormers
- **Stable Diffusion WebUI Forge** (cloned fresh on build)
- **Jupyter Lab** on port 8888
- **NGINX** reverse proxy on port 3001
- **Automatic workspace setup** integration

## ⚙️ Automatic Setup Script

Place your setup script at `/workspace/setup.sh` and it runs automatically after all services start.

**Example `/workspace/setup.sh`:**
```bash
#!/bin/bash
set -e

# Clone your automation repo
git clone https://github.com/your-username/your-project.git

# Copy model files
cp /workspace/*.safetensors /notebooks/stable-diffusion-webui-forge/models/Stable-diffusion/
```


## 📝 Environment Variables

- `BRANCH_ID` - Custom script branch (default: `main`)
- `PLATFORM_ID` - Platform identifier (default: `RUNPOD`)

---

**Image:** `<your-username>/forge-webui-cloud:latest`  
**Auto-publishes:** Every push to main branch via GitHub Actions
