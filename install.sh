#!/bin/bash

REPO_URL="https://github.com/veltrix-capital/test-devops-orchestrators.git"
REPO_DIR="test-devops-orchestrators"

NODE_VERSION=$(node --version 2>&1 | egrep -o 'v[0-9]+' | sed 's/v//')
if [ -n "$NODE_VERSION" ] && [ "$NODE_VERSION" -lt 18 ]; then
    echo "[+] Please update Node.js to version 18 or higher. Current version: v$NODE_VERSION"
    exit 1
fi

# Step 1: Clone or update the repository
if [ -d "$REPO_DIR/.git" ]; then
    echo "[+] Repository exists. Pulling latest changes..."
    cd "$REPO_DIR" && git pull
else
    echo "[+] Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR" || { echo "Failed to enter directory"; exit 1; }
fi

# Step 2: Make scripts executable
echo "[+] Granting execution permissions..."
chmod +x setup.sh start.sh

# Step 3: Run setup.sh
echo "[+] Running setup.sh..."
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
./setup.sh &> logs/setup_$TIMESTAMP.log

echo "Setup is completed"
