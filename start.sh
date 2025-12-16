#!/bin/bash
set -euo pipefail

LOG_FILE="./script_output.log"
exec &> >(tee -a "$LOG_FILE")
log_msg() { local level=$1; shift; echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*"; }
info() { log_msg INFO "$*"; }
error() { log_msg ERROR "$*" >&2; exit 1; }
echo "[Validator] Starting the validator service..."

# Ensure .env exists
if [ ! -f .env ]; then
    echo "[ERROR] Missing .env file. Please run setup.sh first."
    exit 1
fi

# Run orchestrator logic
echo "[Validator] Starting Orchestrator..."

APP_COMMAND="npm start" # The actual command to start your Node.js application
APP_NAME="appjsfile"
HEALTH_CHECK_URL="http://localhost:3000/health" # Adjust to your app's actual health endpoint

cleanup() {
    info "Shutdown signal received. Terminating background processes."
    # Use 'pkill' to terminate the app command safely, if it's running
    pkill -TERM -f "$APP_COMMAND" || true 
    info "Cleanup complete. Exiting."
    exit 0
}

# Trap signals: Run the 'cleanup' function when script exits
trap cleanup SIGINT SIGTERM SIGHUP

# Function to run the application in the background (as a background task)
start_app_in_background() {
    info "Starting application in the background..."
    # Run the command and redirect its output to the main script output (handled by 'exec tee')
    $APP_COMMAND &
    # Capture the Process ID (PID) of the background task
    APP_PID=$!
    info "$APP_NAME started with PID: $APP_PID"
}

# --- Monitoring/Health Check ---

# Function to verify the application starts up correctly
monitor_startup() {
    info "Running startup health check (waiting for 30 seconds)..."
    for i in {1..30}; do
        if curl --output /dev/null --silent --head --fail "$HEALTH_CHECK_URL"; then
            info "Health check passed! Application is responsive."
            return 0
        fi
        sleep 1
    done
    error "Startup failed: Application did not respond to health check at $HEALTH_CHECK_URL"
}

# --- Main Execution ---

start_app_in_background
monitor_startup

info "Application is running and healthy."
