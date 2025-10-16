#!/bin/bash

# Remove old start.sh from volume if it exists (prevents conflicts)
if [ -f "/workspace/start.sh" ] && [ "$0" != "/workspace/start.sh" ]; then
    echo "Removing old start.sh from volume..."
    rm -f /workspace/start.sh
fi

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
    cd /workspace
    jupyter lab \
        --allow-root \
        --ip=0.0.0.0 \
        --no-browser \
        --ServerApp.root_dir=/workspace \
        --ServerApp.trust_xheaders=True \
        --ServerApp.disable_check_xsrf=False \
        --ServerApp.allow_remote_access=True \
        --ServerApp.allow_origin='*' \
        --ServerApp.allow_credentials=True \
        --FileContentsManager.delete_to_trash=False \
        --FileContentsManager.always_delete_dir=True \
        --ContentsManager.allow_hidden=True \
        --LabServerApp.copy_absolute_path=True \
        --ServerApp.token='' \
        --ServerApp.password='' &>/workspace/jupyter.log &
    echo "Jupyter Lab started from /workspace"
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >>/etc/rp_environment 2>/dev/null || true
    echo 'source /etc/rp_environment' >>~/.bashrc 2>/dev/null || true
    echo "Environment variables exported."
}

install_forge_webui() {
    if [ ! -d "/workspace/stable-diffusion-webui-forge" ]; then
        echo "Forge WebUI Neo not found, installing to /workspace..."
        cd /workspace
        git clone --depth 1 https://github.com/Haoming02/sd-webui-forge-classic.git --branch neo stable-diffusion-webui-forge
        echo "Forge WebUI Neo cloned successfully"
        echo "Dependencies will be installed on first launch"
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
    echo "Starting Forge WebUI Neo..."
    cd /workspace/stable-diffusion-webui-forge
    # Force venv location to workspace (persists across restarts)
    export VENV_DIR="/workspace/stable-diffusion-webui-forge/venv"
    # Forge Neo's launch.py handles dependency installation automatically
    python3 launch.py --listen --port 7860 --api --skip-torch-cuda-test --xformers &>/workspace/forge.log &
    echo "Forge WebUI started (initializing in background, tail forge.log for progress)"
}

run_workspace_setup() {
    if [ -f "/workspace/setup.sh" ]; then
        echo "Found /workspace/setup.sh, executing..."
        chmod +x /workspace/setup.sh
        cd /workspace
        bash /workspace/setup.sh
    else
        echo "No setup script found at /workspace/setup.sh (skipping...)"
    fi
}

echo "=== Pod Starting ==="
configure_dns || echo "DNS config failed, continuing..."
export_env_vars || echo "Env vars export failed, continuing..."
install_forge_webui || echo "Forge installation failed!"
update_webui_forge || echo "Forge update check failed, continuing..."
start_forge_webui || echo "Forge startup failed!"
start_jupyter || echo "Jupyter startup failed!"
run_workspace_setup || echo "Workspace setup failed, continuing..."
echo "=== Start script finished, pod is ready ==="
sleep infinity
