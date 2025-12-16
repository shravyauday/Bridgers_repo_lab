#!/bin/bash

set -euo pipefail

LOG_FILE="./script_output.log"
exec &> >(tee -a "$LOG_FILE")
log_msg() { local level=$1; shift; echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*"; }
info() { log_msg INFO "$*"; }
error() { log_msg ERROR "$*" >&2; exit 1; }

REPO_URL="https://github.com/swft-blockchain/test-devops-1.git"
REPO_DIR="test-devops-1"

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
./setup.sh

echo "Setup is completed"
