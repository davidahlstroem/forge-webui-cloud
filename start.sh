#!/bin/bash
export BRANCH_ID=${BRANCH_ID:-main}
export PLATFORM_ID="RUNPOD"

configure_dns() {
    echo "Configuring DNS settings..."
    cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true
    echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf 2>/dev/null || echo "Could not modify DNS, continuing..."
    echo "DNS configuration completed."
}

# Start jupyter lab
start_jupyter() {
    echo "Starting Jupyter Lab..."
    cd /notebooks/
    jupyter lab \
        --allow-root \
        --ip=0.0.0.0 \
        --no-browser \
        --ServerApp.trust_xheaders=True \
        --ServerApp.disable_check_xsrf=False \
        --ServerApp.allow_remote_access=True \
        --ServerApp.allow_origin='*' \
        --ServerApp.allow_credentials=True \
        --FileContentsManager.delete_to_trash=False \
        --FileContentsManager.always_delete_dir=True \
        --FileContentsManager.preferred_dir=/notebooks \
        --ContentsManager.allow_hidden=True \
        --LabServerApp.copy_absolute_path=True \
        --ServerApp.token='' \
        --ServerApp.password='' &>./jupyter.log &
    echo "Jupyter Lab started"
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >>/etc/rp_environment 2>/dev/null || true
    echo 'source /etc/rp_environment' >>~/.bashrc 2>/dev/null || true
    echo "Environment variables exported."
}

make_directory() {
    echo "Creating model directories..."
    mkdir -p /workspace/models/{checkpoints,vae,text-encoder,gfpgan,embeddings,hypernetwork,esrgan,clip,controlnet,loras} || true
    echo "Directories created."
}

install_forge_webui() {
    if [ ! -d "/workspace/stable-diffusion-webui-forge" ]; then
        echo "Forge WebUI not found, installing to /workspace..."
        cd /workspace
        git clone --depth 1 https://github.com/lllyasviel/stable-diffusion-webui-forge.git
        cd stable-diffusion-webui-forge
        pip install --no-cache-dir -r requirements_versions.txt
        echo "Forge WebUI installed successfully"
    else
        echo "Forge WebUI already installed at /workspace/stable-diffusion-webui-forge"
    fi
}

update_webui_forge() {
    echo "Checking for WebUI Forge updates..."
    if [ -d "/workspace/stable-diffusion-webui-forge" ]; then
        cd /workspace/stable-diffusion-webui-forge && git pull --ff-only || echo "Git pull failed, continuing..."
    fi
    export TORCH_FORCE_WEIGHTS_ONLY_LOAD=1
    echo "WebUI Forge update check completed"
}

start_forge_webui() {
    echo "Starting Forge WebUI..."
    echo "This may take 5-10 minutes on first startup..."
    cd /workspace/stable-diffusion-webui-forge
    python3 launch.py --listen --port 7860 --api --skip-torch-cuda-test --xformers &>/notebooks/forge.log &
    echo "Forge WebUI started (initializing in background, check forge.log for progress)"
}

run_workspace_setup() {
    if [ -f "/workspace/setup.sh" ]; then
        echo "Found /workspace/setup.sh, executing..."
        chmod +x /workspace/setup.sh
        cd /workspace
        if bash /workspace/setup.sh; then
            echo "Workspace setup completed successfully!"
        fi
    else
        echo "No setup script found at /workspace/setup.sh"
    fi
}

echo "=== Pod Starting ==="
echo "Platform: $PLATFORM_ID"
echo "Branch: $BRANCH_ID"
configure_dns || echo "DNS config failed, continuing..."
export_env_vars || echo "Env vars export failed, continuing..."
make_directory || echo "Directory creation failed, continuing..."
install_forge_webui || echo "Forge installation failed!"
update_webui_forge || echo "Forge update check failed, continuing..."
start_forge_webui || echo "Forge startup failed!"
start_jupyter || echo "Jupyter startup failed!"
run_workspace_setup || echo "Workspace setup failed, continuing..."
echo "=== Start script finished, pod is ready ==="
sleep infinity
