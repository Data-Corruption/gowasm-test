#!/bin/bash

set -e  # Exit on any error
set -o pipefail  # Catch errors in piped commands

# Logging functions
log_info() { echo -e "🔵 $1"; }
log_success() { echo -e "🟢 $1"; }
log_warning() { echo -e "🟡 $1"; }
log_error() { echo -e "🔴 $1"; exit 1; }

# Parse command-line arguments
AUTO_CONFIRM=false
for arg in "$@"; do
    case $arg in
        -y|-f) AUTO_CONFIRM=true ;;
        *) log_error "Invalid option: $arg";;
    esac
done

# Check required commands
for cmd in go curl npm; do
    command -v "$cmd" >/dev/null 2>&1 || log_error "Missing required command: $cmd"
done

# Define variables
GOROOT=$(go env GOROOT)
WASM_EXEC_SRC="$GOROOT/lib/wasm/wasm_exec.js"
WASM_EXEC_DEST="./frontend/js/"
TAILWIND_URL="https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64"
TAILWIND_DEST="./frontend/css/tailwindcss"

# Ensure required directories exist
mkdir -p "$WASM_EXEC_DEST" "./frontend/css"

# Copy wasm_exec.js
log_info "Copying wasm_exec.js from $WASM_EXEC_SRC to $WASM_EXEC_DEST..."
[ -f "$WASM_EXEC_SRC" ] && cp "$WASM_EXEC_SRC" "$WASM_EXEC_DEST" || log_error "wasm_exec.js not found at $WASM_EXEC_SRC"

# Check for TailwindCSS binary
DOWNLOAD_TAILWIND=true
if [ -f "$TAILWIND_DEST" ]; then
    log_warning "TailwindCSS binary already exists at $TAILWIND_DEST."
    if [ "$AUTO_CONFIRM" = false ]; then
        read -p "Do you want to overwrite it? (y/n): " choice
        case "$choice" in
            y|Y) log_info "Downloading TailwindCSS..." ;;
            *) log_info "Skipping TailwindCSS."; DOWNLOAD_TAILWIND=false ;;
        esac
    else
        log_info "Downloading TailwindCSS..."
    fi
else
    log_info "Downloading TailwindCSS..."
fi

# Download TailwindCSS if needed
if [ "$DOWNLOAD_TAILWIND" = true ]; then
    TEMP_FILE=$(mktemp)
    if curl -L "$TAILWIND_URL" -o "$TEMP_FILE"; then
        mv "$TEMP_FILE" "$TAILWIND_DEST"
        chmod +x "$TAILWIND_DEST"
        log_success "TailwindCSS downloaded and made executable!"
    else
        log_error "Failed to download TailwindCSS."
    fi
fi

# Install NPM dependencies if package.json exists
if [ -f "package.json" ]; then
    log_info "Installing NPM dependencies..."
    if [ -f "package-lock.json" ]; then
        npm ci && log_success "NPM dependencies installed using 'npm ci'!"
    else
        npm install && log_success "NPM dependencies installed using 'npm install'!"
    fi
else
    log_error "Missing package.json found. Skipping NPM install."
fi

log_success "Setup complete!"