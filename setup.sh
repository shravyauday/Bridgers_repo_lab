#!/bin/bash

set -euo pipefail

LOG_FILE="./script_output.log"
exec &> >(tee -a "$LOG_FILE")
log_msg() { local level=$1; shift; echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*"; }
info() { log_msg INFO "$*"; }
error() { log_msg ERROR "$*" >&2; exit 1; }
echo "[Validator Setup] Starting setup..."

# Detect OS and install Node.js if missing
OS="$(uname -s)"
NODE_VERSION="$(node -v | cut -c 2- | cut -d'.' -f 1)"
if [ $NODE_VERSION -ge 18 ]; then
    echo "[INFO] Node.js installed is $NODE_VERSION"
else
    echo "[INFO] Node.js installed is $NODE_VERSION which is older than what we expect"
fi

detect_and_install_node() {
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        echo "[INFO] Node.js already installed: $(node -v)"
        echo "[INFO] npm version: $(npm -v)"
        return
    fi

    echo "[INFO] Node.js or npm not found. Attempting installation..."

    case "$OS" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                echo "[INFO] Installing Node.js via apt..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt install -y nodejs
            elif [ -f /etc/redhat-release ]; then
                echo "[INFO] Installing Node.js via yum..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            else
                echo "[WARN] Unsupported Linux distro. Please install Node.js manually."
                exit 1
            fi
            ;;
        Darwin*)
            if command -v brew &>/dev/null; then
                echo "[INFO] Installing Node.js via Homebrew..."
                brew install node
            else
                echo "[ERROR] Homebrew not found. Please install Node.js manually."
                exit 1
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "[INFO] Detected Windows (Git Bash or WSL). Please install Node.js manually from https://nodejs.org/"
            exit 1
            ;;
        *)
            echo "[ERROR] Unknown OS: $OS"
            exit 1
            ;;
    esac
}

detect_and_install_node

# Prepare logs directory
mkdir -p logs

# Install dependencies
echo "[INFO] Installing Node.js dependencies..."
npm install
npm run dev

# Prepare .env file
if [ ! -f .env ]; then
    if [ -f .env_example ]; then
        cp .env_example .env
        echo "[INFO] Copied .env_example to .env"
    else
        echo "[ERROR] No .env or .env_example found. Cannot continue."
        exit 1
    fi
fi

echo "[Validator Setup] Setup complete."
./start.sh
