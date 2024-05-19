#!/bin/bash

echo "[Validator] Starting the validator service..."

# Ensure .env exists
if [ ! -f .env ]; then
    echo "[ERROR] Missing .env file. Please run setup.sh first."
    exit 1
fi

# Run orchestrator logic
echo "[Validator] Starting Orchestrator..."
npm start
